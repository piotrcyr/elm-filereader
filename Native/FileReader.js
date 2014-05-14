Elm.Native.FileReader = {};
Elm.Native.FileReader.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.FileReader = elm.Native.FileReader || {};
    if (elm.Native.FileReader.values) return elm.Native.FileReader.values;

    var Signal      = Elm.Signal.make(elm);
    var Utils       = Elm.Native.Utils.make(elm);
    var fromTime    = Elm.Native.Date.make(elm).fromTime;
    var newElement  = Elm.Graphics.Element.make(elm).newElement;
    var newNode     = ElmRuntime.use(ElmRuntime.Render.Utils).newElement;
    
    function renderFileInput(model) {        
        var node = newNode('input');
        node.type = 'file'
        node.style.display = 'block';
        node.style.pointerEvents = 'auto';
        node.elm_signal = model.signal;
        node.elm_handler = model.handler;
        function change() {
            var file    = node.files[0]
                        ? { ctor:"Just", _0:node.files[0] }
                        : { ctor:"Nothing" }
                        ;
            elm.notify(node.elm_signal.id, node.elm_handler(file));
        }
        node.addEventListener('change', change);
        return node;
    }

    function updateFileInput(node, oldModel, newModel) {
    }

    function fileInput(signal, handler) {
        return A3(newElement, 200, 24, {
            ctor: 'Custom',
            type: 'FileInput',
            render: renderFileInput,
            update: updateFileInput,
            model: { signal:signal, handler:handler }
        });
    } 

    function fileDroppable(signal, elem){
        
        function onDrop(event) {
            console.log(event)
            var file    = event.dataTransfer.files[0]
                        ? { ctor:"Just", _0:event.dataTransfer.files[0] }
                        : { ctor:"Nothing" }
                        ;
            elm.notify(signal.id, handler(file));
        }        
        var props = Utils.replace([['drop', onDrop]], elem.props);
        console.log(props, elem)
        //elem.addEventListener('drop', onDrop);
        return { props:props, element:elem.element };
    }

    function readAsText(file){
              
        if (!file.reader || !file.fileReader){
            
            var reader = (file.reader = new FileReader());
            var fileReader = (file.fileReader = Signal.constant({ ctor:'Ready' }));
            
            reader.onerror = function(event) {
                console.log(event)
                //elm.notify(fileReader.id, { ctor:'Error', _0: });
            };

            reader.onprogress = function(event) {
                if (event.lengthComputable) {
                    elm.notify(fileReader.id, { ctor:'Progress', _0:event.total, _1:event.loaded});
                } else {
                    elm.notify(fileReader.id, { ctor:'Progress', _0:0, _1:event.loaded});               
                }            
            };

            reader.onloadend = function(event) {
                this.running = false;
                elm.notify(fileReader.id, { ctor:'Success', _0:event.target.result})
            };
        }
        
        var reader = file.reader;
        var fileReader = file.fileReader;

        function updateReader(file) {        
            if (file.ctor !== "Nothing"){               
                if (!reader.running){                    
                    reader.running = true;
                    reader.readAsText(file._0);
                }
            }
            setTimeout(function(){ elm.notify(fileReader.id, { ctor:'Ready' }); },0);
            return fileReader;
        }

        function take1(x,y) { return x; }
        // lift2 (\x y -> x) fileReader (lift updateReader file)
        return A3(Signal.lift2, F2(take1), fileReader, A2(Signal.lift, updateReader, file));
        //return A2(Signal.lift, updateReader, file).value;
    }

    function slice(start, end, blob) {
        return blob.slice(start, end);
    }

    function mimeType(blob) {
        return blob.type ? { ctor:'Just', _0:blob.type } : { ctor:'Nothing' };
    }

    return elm.Native.FileReader.values = {
        fileInput  : F2(fileInput),
        fileDroppable  : F2(fileDroppable),
        readAsText : readAsText,
        slice      : F3(slice),
        mimeType   : mimeType,
    };

};