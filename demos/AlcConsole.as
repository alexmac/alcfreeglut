package flascc
{
  import flash.display.Bitmap
  import flash.display.BitmapData
  import flash.display.DisplayObjectContainer;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.display.Stage3D;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.display3D.Context3D;
  import flash.display3D.Context3DRenderMode;
  import flash.events.AsyncErrorEvent;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.ProgressEvent;
  import flash.events.SampleDataEvent;
  import flash.events.SecurityErrorEvent;
  import flash.geom.Rectangle
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.net.LocalConnection;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.ui.Mouse;
  import flash.utils.ByteArray
  import flash.utils.ByteArray;
  import flash.utils.Endian;
  import flash.utils.getTimer;
  
  import GLS3D.GLAPI;
  import flascc.vfs.ISpecialFile;

  public class Console extends Sprite implements ISpecialFile
  {
    private var enableConsole:Boolean = false;
    private static var _width:int = 500;
    private static var _height:int = 500;
    private var mainloopTickPtr:int, keyHandlerPtr:int;
    private var _tf:TextField;
    private var inputContainer
    private var keybytes:ByteArray = new ByteArray()
    private var mx:int = 0, my:int = 0, last_mx:int = 0, last_my:int = 0, button:int = 0, kp:int = 0;
    private var snd:Sound = null
    private var sndChan:SoundChannel = null
    public var sndDataBuffer:ByteArray = null
    private var _stage:Stage3D;
    private var _context:Context3D;
    private var rendered:Boolean = false;
    private var datazip:URLLoader;

    /**
    * A basic implementation of a console for flascc apps.
    * The PlayerPosix class delegates to this for things like read/write
    * so that console output can be displayed in a TextField on the Stage.
    */
    public function Console(container:DisplayObjectContainer = null)
    {
      CModule.rootSprite = container ? container.root : this

      if(CModule.runningAsWorker()) {
        return;
      }

      if(container) {
        container.addChild(this)
        init(null)
      } else {
        addEventListener(Event.ADDED_TO_STAGE, init)
      }
    }

    public function send(value:String):void
    {
        trace(value)
    }

    private function onError(e:Event):void
    {
    }

    private function onProgress(e:Event):void
    {
    }

    private function init(e:Event):void
    {
      try {
        var ns:Namespace = new Namespace("flascc.vfs");
        CModule.vfs.addBackingStore(new ns::RootFSBackingStore(), null)
      } catch(e:*) {
        // a zip based fs wasn't supplied
      }
      
      inputContainer = new Sprite()
      addChild(inputContainer)

      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.addEventListener(KeyboardEvent.KEY_DOWN, bufferKeyDown);
      stage.addEventListener(KeyboardEvent.KEY_UP, bufferKeyUp);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, bufferMouseMove);
      stage.addEventListener(MouseEvent.MOUSE_DOWN, bufferMouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, bufferMouseUp);
      stage.frameRate = 60;
      stage.scaleMode = StageScaleMode.NO_SCALE;

      if(enableConsole) {
      _tf = new TextField;
      _tf.multiline = true;
      _tf.width = _width;
      _tf.height = _height;
      inputContainer.addChild(_tf);
      }
    
    _stage = stage.stage3Ds[0];
    _stage.addEventListener(Event.CONTEXT3D_CREATE, context_created);
    //_stage.requestContext3D(Context3DRenderMode.AUTO);
    _stage.requestContext3D("auto");
  }

  private function context_created(e:Event):void
  {
      _context = _stage.context3D;
      _context.configureBackBuffer(_width, _height, 4, true /*enableDepthAndStencil*/ );
      _context.enableErrorChecking = false;
      
      trace(_context.driverInfo);
      GLAPI.init(_context, null, stage);
      var gl:GLAPI = GLAPI.instance;
      //gl.log = this;
      gl.context.clear(0.0, 0.0, 0.0);
      gl.context.present();
      gl.context.clear(0.0, 0.0, 0.0);
      this.addEventListener(Event.ENTER_FRAME, runMain);
      stage.addEventListener(Event.RESIZE, stageResize);
    }
    
    private function stageResize(event:Event):void
    {
        // need to reconfigure back buffer
        _width = stage.stageWidth;
        _height = stage.stageHeight;
        _context.configureBackBuffer(_width, _height, 4, true /*enableDepthAndStencil*/ );
    }


    private function runMain(event:Event):void
    {
      this.removeEventListener(Event.ENTER_FRAME, runMain);
      var argv:Vector.<String> = new Vector.<String>();
      argv.push("/data/neverball.swf");
      CModule.startAsync(this, argv);
      mainloopTickPtr = CModule.getPublicSymbol("glutMainLoopBody");
      keyHandlerPtr = CModule.getPublicSymbol("_avm2_glut_keyhandler");

      framebufferBlit(null);
      addEventListener(Event.ENTER_FRAME, framebufferBlit);
    }

    /**
    * The PlayerPosix implementation will use this function to handle
    * C IO write requests to the file "/dev/tty" (e.g. output from
    * printf will pass through this function). See the ISpecialFile
    * documentation for more information about the arguments and return value.
    */
    public function write(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      var str:String = CModule.readString(bufPtr, nbyte)
      consoleWrite(str)
      return nbyte
    }

    public function read(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      if(fd == 0 && nbyte == 1) {
        keybytes.position = kp++
        if(keybytes.bytesAvailable) {
          CModule.write8(bufPtr, keybytes.readUnsignedByte())
        } else {
          keybytes.position = 0
          kp = 0
        }
      }
      return 0
    }

    public function bufferMouseMove(me:MouseEvent) {
      me.stopPropagation()
      mx = me.stageX
      my = me.stageY
    }
    
    public function bufferMouseDown(me:MouseEvent) 
    {
      me.stopPropagation();
      mx = me.stageX;
      my = me.stageY;
      button = 1;
    }
    
    public function bufferMouseUp(me:MouseEvent) 
    {
      me.stopPropagation();
      mx = me.stageX;
      my = me.stageY;
      button = 0;
    }

    private var keyhandlerargs:Vector.<int> = new Vector.<int>(3);

    public function bufferKeyDown(ke:KeyboardEvent) 
    {
      ke.stopPropagation();

      keyhandlerargs[0] = ke.keyCode;
      keyhandlerargs[1] = ke.charCode;
      keyhandlerargs[2] = 0;
      keyhandlerargs[3] = mx;
      keyhandlerargs[4] = my;
      CModule.callI(keyHandlerPtr, keyhandlerargs);
    }
    
    public function bufferKeyUp(ke:KeyboardEvent) 
    {
      ke.stopPropagation();

      keyhandlerargs[0] = ke.keyCode;
      keyhandlerargs[1] = ke.charCode;
      keyhandlerargs[2] = 0;
      keyhandlerargs[3] = mx;
      keyhandlerargs[4] = my;
      CModule.callI(keyHandlerPtr, keyhandlerargs);
    }

    public function consoleWrite(s:String):void
    {
      trace(s)
      if(enableConsole) {
        _tf.appendText(s);
        _tf.scrollV = _tf.maxScrollV
      }
    }

    public function framebufferBlit(e:Event):void
    {
      CModule.serviceUIRequests()
      var gl:GLAPI = GLAPI.instance;
      CModule.callI(mainloopTickPtr, new Vector.<int>());
      gl.context.present();
      gl.context.clear(1.0, 0.0, 0.0);
    }
  }
}
