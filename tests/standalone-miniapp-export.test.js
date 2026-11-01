#!/usr/bin/env node
'use strict';

// Standalone mini-app export/security contract tests.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const html = fs.readFileSync('www/index.html', 'utf8');
const start = html.indexOf('    function standaloneRuntimeBootstrap(config) {');
const end = html.indexOf('    /** Export mini-app as standalone browser HTML (no keys unless explicitly selected). */', start);
assert.ok(start >= 0 && end > start, 'standalone export helpers must exist');
const source = html.slice(start, end);
const sandbox = {
  getProviderMap: () => ({}), getProfiles: () => ({}), getKnownKeys: () => [],
  currentProviderId: () => 'openai', el: { apiBase:{value:''}, model:{value:''}, apiKey:{value:''} },
  maskKey: x => '••••' + String(x).slice(-4), URL,
};
vm.runInNewContext(source + '\nthis.standaloneApi = { standaloneRuntimeBootstrap, standaloneProviderData, buildStandaloneRuntimeSource, injectStandaloneRuntime };', sandbox);
const api = sandbox.standaloneApi;
let passed = 0;
function test(name, fn) { fn(); passed++; console.log('✓ ' + name); }

const providerData = {
  selectedProvider: 'openai',
  providers: [{ id:'openai', label:'OpenAI', base:'https://api.openai.com/v1', model:'gpt-4o-mini', auth:'bearer', kind:'openai', key:'' }],
  choices: [{ id:'openai', label:'OpenAI', model:'gpt-4o-mini', candidates:[{ key:'sk-SUPER-SECRET-test', label:'Saved key · ••••test' }] }],
};
const app = { id:'demo_app', title:'Demo', html:'<!doctype html><html><head><title>Demo</title></head><body><script>window.started=true;</script></body></html>' };

test('preview and Library expose distinct Export standalone and Share mini-app actions', () => {
  assert.match(html, /id="btnExport"[^>]*title="Export standalone HTML"/);
  assert.match(html, /id: 'share', label: t\('lib\.share'\)/);
  assert.match(html, /id: 'export', label: t\('lib\.export'\)/);
  assert.match(html, /else if \(choice === 'share'\) shareAppToAaforge\(fresh\)/);
  assert.match(html, /choice === 'share'\) shareAppToAaforge\(fresh\)/);
  assert.match(html, /choice === 'export'\) exportApp\(fresh, \{ source: 'library' \}\)/);
});

test('export dialog has no Forge-HTML option and keeps both standalone export choices', () => {
  assert.match(html, /chooseStandaloneExport\(app,\s*forgeChatEnabled\)/);
  assert.match(html, /mode:'standalone',keys:\[\]/);
  assert.doesNotMatch(html, /Export Forge HTML|data-action="forge"|mode:'forge'/);
  assert.match(html, /Export standalone · no keys/);
  assert.match(html, /Export for ForgeChat · no keys/);
  assert.match(html, /data-action="forgechat"/);
  assert.match(html, /Embed selected keys &amp; export/);
  assert.match(html, /standalone-export-panel/);
  assert.match(html, /standalone-export-actions/);
});

test('ForgeChat hosted runtime implements server TTS and file staging', () => {
  assert.match(source, /function serverTtsVoices/);
  assert.match(source, /function serverTtsToAgent/);
  assert.match(source, /if\(opts\.inline===false\)/);
  assert.match(source, /tts\/synthesize-to-agent/);
  assert.match(source, /ttsToFile: async function\(opts\)\{if\(serverMode\)return serverTtsToAgent/);
  assert.match(source, /if\(serverMode\)\{host\.termux=serverTermux;host\.tts=serverTts;\}/);
  const videoLingo=fs.readFileSync('samples/VideoLingo.html','utf8');
  assert.match(videoLingo, /synthesized&&synthesized\.agentPath/);
  assert.match(videoLingo, /cloudAudio&&cloudAudio\.agentPath/);
  assert.match(videoLingo, /value="vm">ForgeChat VM \(offline\)/);
  assert.match(videoLingo, /engine:"local"/);
  assert.match(videoLingo, /av&&av\.bridge==="backend-agent"/);
  assert.match(videoLingo, /F\.termux\.writeFile\(upload\)/);
  assert.match(videoLingo, /The backend-agent command or upload was not approved/);
  assert.doesNotMatch(videoLingo, /picked=\{name:inputName/, 'retain browser File so processing can be retried after cancel');
  assert.doesNotMatch(videoLingo, /loadTtsVoices\(\);getFfmpegReady\(\)/, 'ffmpeg agent command must not run during app startup');
  assert.match(videoLingo, /try\{await getFfmpegReady\(\);status\("Extracting audio/,'ffmpeg remains checked when the user starts processing');
});

test('ForgeChat HTML export is hidden only for the Play flavor', () => {
  const gradle = fs.readFileSync('android/app/build.gradle', 'utf8');
  const appsBridge = fs.readFileSync('android/app/src/main/java/com/forge/live/AppsBridgePlugin.java', 'utf8');
  assert.match(gradle, /full\s*\{[\s\S]*?buildConfigField "boolean", "FORGECHAT_HTML_EXPORT_ENABLED", "true"/);
  assert.match(gradle, /play\s*\{[\s\S]*?buildConfigField "boolean", "FORGECHAT_HTML_EXPORT_ENABLED", "false"/);
  assert.match(appsBridge, /caps\.put\("forgeChatHtmlExport", BuildConfig\.FORGECHAT_HTML_EXPORT_ENABLED\)/);
  assert.match(html, /forgeChatHtmlExportEnabled\(\)/);
  assert.match(html, /capabilities\?\.forgeChatHtmlExport === true/);
  assert.match(html, /if\(!forgeChatEnabled\) panel\.querySelectorAll\('\.forgechat-export-only,\[data-action="forgechat"\]'\)/);
  assert.match(html, /if\(forgeChatEnabled\) panel\.querySelector\('\[data-action="forgechat"\]'\)/);
  assert.match(html, /choice\.mode === 'forgechat' && !forgeChatEnabled/);
});

test('provider-key selection requires explicit acknowledgement and defaults unchecked', () => {
  assert.match(html, /No Forge-saved LLM keys are included by default/);
  assert.match(html, /recoverable by anyone with the exported HTML/);
  assert.match(html, /standalone-ack/);
  assert.match(html, /if\(!panel\.querySelector\('#standalone-ack'\)\.checked\)/);
  assert.match(html, /none selected by default/);
});

test('no-secret export source does not contain a configured key', () => {
  const generated = api.buildStandaloneRuntimeSource(app, providerData, []);
  assert.ok(!generated.includes('sk-SUPER-SECRET-test'));
  assert.ok(generated.includes('"keysEmbedded":false'));
});

test('ForgeChat export uses a same-origin API path and strips all provider credentials/config', () => {
  const generated = api.buildStandaloneRuntimeSource(app, providerData, [{id:'openai',key:'NEVER-IN-HTML'}], {mode:'forgechat',apiBase:'/forgechat'});
  assert.ok(!generated.includes('sk-SUPER-SECRET-test'));
  assert.ok(!generated.includes('NEVER-IN-HTML'));
  assert.ok(generated.includes('"backend":"forgechat"'));
  assert.ok(generated.includes('"apiBase":"/forgechat"'));
  assert.ok(generated.includes('"providers":[]'));
  assert.ok(generated.includes('"keysEmbedded":false'));
});

test('only explicitly selected provider/key pairs are embedded', () => {
  const generated = api.buildStandaloneRuntimeSource(app, providerData, [{ id:'openai', key:'sk-SUPER-SECRET-test' }]);
  assert.ok(generated.includes('sk-SUPER-SECRET-test'));
  assert.ok(generated.includes('"keysEmbedded":true'));
  const other = api.buildStandaloneRuntimeSource(app, providerData, [{ id:'openai', key:'chosen-key' }]);
  assert.ok(!other.includes('sk-SUPER-SECRET-test'));
  assert.ok(other.includes('chosen-key'));
});

test('provider snapshot strips URL credentials/query and keeps keys separate from default config', () => {
  sandbox.getProviderMap = () => ({ custom: { id:'custom', label:'Custom', base:'https://user:pw@llm.example/v1?token=URL_SECRET#frag', defaultModel:'m1', auth:'bearer', custom:true } });
  sandbox.getProfiles = () => ({ custom: { key:'PROFILE_SECRET', model:'m2' } });
  sandbox.getKnownKeys = () => [];
  sandbox.currentProviderId = () => 'custom';
  sandbox.el = { apiBase:{value:''}, model:{value:''}, apiKey:{value:''}, azureResource:{value:''}, azureDeployment:{value:''}, azureApiVersion:{value:''}, azureAuth:{value:''} };
  const snapshot = vm.runInNewContext('standaloneProviderData()', sandbox);
  assert.equal(snapshot.providers[0].base, 'https://llm.example/v1');
  assert.equal(snapshot.providers[0].key, '');
  const generated = api.buildStandaloneRuntimeSource(app, snapshot, []);
  assert.ok(!generated.includes('URL_SECRET'));
  assert.ok(!generated.includes('PROFILE_SECRET'));
});

test('HTML injection is standalone and happens before app scripts', () => {
  const generated = api.buildStandaloneRuntimeSource(app, providerData, []);
  const output = api.injectStandaloneRuntime(app, generated);
  assert.ok(output.indexOf('standaloneRuntimeBootstrap') < output.indexOf('window.started=true'));
  assert.match(output, /<head><script>/);
});

test('embedded credential strings are escaped before insertion into a script element', () => {
  const payload = '</script><script>alert(1)</script>';
  const generated = api.buildStandaloneRuntimeSource(app, providerData, [{id:'openai',key:payload}]);
  assert.ok(!generated.includes('</script>'));
  assert.ok(generated.includes('\\u003c/script>'));
});

test('export runtime exposes browser APIs, chat-only ForgeChat agent fallback, and rejects Forge-only APIs', () => {
  assert.match(source, /chat: chat/);
  assert.match(source, /chatStream: async function/);
  assert.match(source, /var tools = \{/);
  assert.match(source, /run: async function\(nameOrOpts, args\)/);
  assert.match(source, /image_generate/);
  assert.match(source, /CORS\/network restriction/);
  assert.match(source, /agent: async function\(opts\)/);
  assert.match(source, /toolMode='chat-only'/);
  assert.match(source, /toolsUnavailable=true/);
  assert.match(source, /ai\.runTask \(host-managed agent loop is Forge-only\)/);
  assert.match(source, /Enter an API key/);
  assert.match(source, /for this tab only/);
});

test('browser-only export details are separate from the ForgeHost API reference', () => {
  const apiDocs=fs.readFileSync('docs/api.md','utf8');
  const builderApi=fs.readFileSync('www/API.md','utf8');
  const exportDocs=fs.readFileSync('docs/standalone-export.md','utf8');
  assert.doesNotMatch(apiDocs,/Standalone browser export|browser runtime implements a limited subset/);
  assert.doesNotMatch(builderApi,/Standalone browser export|browser runtime implements a limited subset/);
  assert.match(apiDocs,/Forge Host API reference/);
  assert.match(exportDocs,/not embed Forge-saved AI keys by default/);
  assert.match(exportDocs,/camera\.takePhoto/);
  assert.match(exportDocs,/ai\.chat\(\{attachments\}\)/);
  assert.match(exportDocs,/Gemini `inline_data`/);
  assert.match(exportDocs,/live camera preview/);
  assert.match(exportDocs,/camera file/);
  assert.match(exportDocs,/ForgeHost\.ai\.agent\(\)/);
  assert.match(exportDocs,/toolsUnavailable/);
});

async function exerciseStandaloneImageTool() {
  const imageData={selectedProvider:'xai',providers:[{id:'xai',label:'xAI',base:'https://api.x.ai/v1',model:'grok-imagine-image',auth:'bearer',kind:'openai',key:''}]};
  const generated=api.buildStandaloneRuntimeSource(app,imageData,[{id:'xai',key:'selected-image-key'}]);
  let requestUrl='',requestInit=null,confirmCount=0;
  const ctx={window:{confirm(){confirmCount++;return true;},prompt(){throw new Error('embedded image key should not prompt');}},navigator:{},document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}};}},localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async function(url,init){requestUrl=url;requestInit=init;return {ok:true,json:async()=>({data:[{url:'https://cdn.example/image.png',revised_prompt:'revised'}]})};},console};
  vm.runInNewContext(generated,ctx);
  const result=await ctx.window.ForgeHost.tools.run({name:'image_generate',args:{prompt:'a red fox',n:2,model:'grok-imagine-image'}});
  assert.equal(requestUrl,'https://api.x.ai/v1/images/generations');
  assert.equal(requestInit.headers.Authorization,'Bearer selected-image-key');
  assert.deepEqual(JSON.parse(requestInit.body),{model:'grok-imagine-image',prompt:'a red fox',n:2});
  assert.equal(result.images[0].url,'https://cdn.example/image.png');
  assert.equal(confirmCount,1,'billable image tool must ask confirmation');
}

async function exerciseChatCorsDiagnostic() {
  const generated=api.buildStandaloneRuntimeSource(app,providerData,[]);
  const ctx={window:{prompt(){return 'session-key';}},navigator:{},document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}}; }},localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async function(){throw new TypeError('Failed to fetch');},console};
  vm.runInNewContext(generated,ctx);
  await assert.rejects(ctx.window.ForgeHost.ai.chat({prompt:'test'}),/CORS\/network restriction.*file:\/\//);
}

async function exerciseXaiOnlySelection() {
  const providerData={selectedProvider:'cheaperinference',providers:[{id:'cheaperinference',label:'Cheaper Inference',base:'https://api.cheaperinference.com/v1',model:'glm-5.2',auth:'bearer',kind:'openai',key:''},{id:'xai',label:'xAI (Grok)',base:'https://api.x.ai/v1',model:'grok-3',auth:'bearer',kind:'openai',key:''}]};
  const generated=api.buildStandaloneRuntimeSource(app,providerData,[{id:'xai',key:'selected-xai-key'}]);
  let prompts=0,requestUrl='';
  const prefix='forge_standalone_demo_app_';
  const ctx={window:{prompt(){prompts++;return ''; }},navigator:{},document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}}; }},localStorage:{getItem(key){return key===prefix+'provider'?JSON.stringify('cheaperinference'):null;},setItem(){},removeItem(){}},fetch:async function(url){requestUrl=url;return {ok:true,json:async()=>({choices:[{message:{content:'xai ok'}}]})};},console};
  vm.runInNewContext(generated,ctx);
  assert.equal((await ctx.window.ForgeHost.ai.getProvider()).providerId,'xai','stale keyless provider preference should not override the embedded provider');
  const result=await ctx.window.ForgeHost.ai.chat({prompt:'hello'});
  assert.equal(result.content,'xai ok');
  assert.equal(requestUrl,'https://api.x.ai/v1/chat/completions');
  assert.equal(prompts,0,'must not ask for Cheaper Inference key when only xAI key was selected');
}

async function exerciseImageFallbackAndNoPrompt() {
  const providerData={selectedProvider:'cheaperinference',providers:[{id:'cheaperinference',label:'Cheaper Inference',base:'https://api.cheaperinference.com/v1',model:'glm-5.2',auth:'bearer',kind:'openai',key:''},{id:'xai',label:'xAI (Grok)',base:'https://api.x.ai/v1',model:'grok-imagine-image',auth:'bearer',kind:'openai',key:''}]};
  const generated=api.buildStandaloneRuntimeSource(app,providerData,[{id:'cheaperinference',key:'cheap-key'},{id:'xai',key:'selected-xai-key'}]);
  const calls=[];let prompts=0;
  const ctx={window:{confirm(){return true;},prompt(){prompts++;return ''; }},navigator:{},document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}}; }},localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async function(url){calls.push(url);if(url.indexOf('cheaperinference')>=0)throw new TypeError('Failed to fetch');return {ok:true,json:async()=>({data:[{url:'https://cdn.example/xai.png'}]})};},console};
  vm.runInNewContext(generated,ctx);
  const result=await ctx.window.ForgeHost.tools.run('image_generate',{prompt:'test image'});
  assert.deepEqual(calls,['https://api.cheaperinference.com/v1/images/generations','https://api.x.ai/v1/images/generations']);
  assert.equal(result.backend,'xai','should continue to the selected xAI key after Cheaper Inference CORS/network failure');
  assert.equal(prompts,0,'selected provider keys should be tried before prompting');
  const xaiOnly=api.buildStandaloneRuntimeSource(app,providerData,[{id:'xai',key:'selected-xai-key'}]);
  calls.length=0;prompts=0;
  const ctx2=Object.assign({},ctx,{window:{confirm(){return true;},prompt(){prompts++;return ''; }}});
  vm.runInNewContext(xaiOnly,ctx2);
  const onlyResult=await ctx2.window.ForgeHost.tools.run('image_generate',{prompt:'test image'});
  assert.equal(onlyResult.backend,'xai');
  assert.deepEqual(calls,['https://api.x.ai/v1/images/generations']);
  assert.equal(prompts,0,'xAI-only export must not prompt for a key for the keyless default provider');
}

async function exerciseLiveBrowserCameraCapture() {
  const generated=api.buildStandaloneRuntimeSource(app,providerData,[{id:'openai',key:'camera-test-key'}]);
  const stopped=[];
  function element(tag){return {tagName:tag,style:{},children:[],attributes:{},listeners:{},videoWidth:640,videoHeight:480,setAttribute(k,v){this.attributes[k]=v;},appendChild(child){this.children.push(child);child.parentNode=this;},removeChild(child){const i=this.children.indexOf(child);if(i>=0)this.children.splice(i,1);child.parentNode=null;},addEventListener(name,fn){this.listeners[name]=fn;},play(){return Promise.resolve();},getContext(){return {drawImage(){}};},toDataURL(){return 'data:image/jpeg;base64,Q0FN';}};}
  const body=element('body');
  const document={readyState:'complete',body,documentElement:body,getElementById(){return null;},createElement:element};
  let constraints=null,chatBody=null;
  const mediaDevices={async getUserMedia(value){
    constraints=value;
    return {getTracks(){return [{stop(){stopped.push(true);}}]}};
  }};
  const ctx={window:{},navigator:{mediaDevices},document,localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async function(url,init){chatBody=JSON.parse(init.body);return {ok:true,json:async()=>({choices:[{message:{content:'photo received'}}]})};},console};
  vm.runInNewContext(generated,ctx);
  const photoPromise=ctx.window.ForgeHost.camera.takePhoto({facing:'back',maxWidth:1024,quality:85});
  await new Promise(resolve=>setTimeout(resolve,0));
  assert.equal(constraints.video.facingMode.ideal,'environment');
  const modal=body.children.find(child=>child.attributes.role==='dialog'),panel=modal.children[0],buttons=panel.children[2].children;
  assert.equal(buttons[2].textContent,'Take photo');
  buttons[2].onclick();
  const photo=await photoPromise;
  assert.equal(photo.dataUrl,'data:image/jpeg;base64,Q0FN');
  assert.equal(photo.width,640);
  assert.equal(stopped.length,1,'camera stream is stopped after the shutter is pressed');
  assert.equal(body.children.some(child=>child.attributes.role==='dialog'),false,'capture dialog is removed after a photo is taken');
  const result=await ctx.window.ForgeHost.ai.chat({prompt:'describe this',attachments:[photo]});
  assert.equal(result.content,'photo received');
  assert.equal(chatBody.messages[0].content[1].image_url.url,'data:image/jpeg;base64,Q0FN');
}

async function exerciseBrowserMediaPickers() {
  const generated=api.buildStandaloneRuntimeSource(app,providerData,[]);
  const queued=[
    {name:'one.jpg',type:'image/jpeg',size:7,dataUrl:'data:image/jpeg;base64,QUJD'},
    {name:'two.txt',type:'text/plain',size:4,dataUrl:'data:text/plain;base64,VEVTVA=='},
    {name:'gallery.png',type:'image/png',size:5,dataUrl:'data:image/png;base64,UE5H'},
    {name:'capture.jpg',type:'image/jpeg',size:6,dataUrl:'data:image/jpeg;base64,SE9U'},
    {name:'video.mp4',type:'video/mp4',size:50,dataUrl:'data:video/mp4;base64,TVA='},
    {name:'too-large.mp4',type:'video/mp4',size:101,dataUrl:'data:video/mp4;base64,TVA='},
  ];
  const inputs=[], children=[];
  const body={appendChild(input){children.push(input);input.parentNode=body;},removeChild(input){const i=children.indexOf(input);if(i>=0)children.splice(i,1);input.parentNode=null;}};
  const document={readyState:'complete',body,getElementById(){return null;},createElement(tag){if(tag!=='input')return {style:{},remove(){}};const input={type:'',accept:'',multiple:false,capture:'',style:{},files:[],setAttribute(k,v){this[k]=v;},click(){this.files=this.multiple?[queued.shift(),queued.shift()]:[queued.shift()];if(this.onchange)this.onchange();},remove(){body.removeChild(this);}};inputs.push(input);return input;}};
  function FakeFileReader(){this.readAsDataURL=function(file){this.result=file.dataUrl;this.onload();};}
  function FakeImage(){}
  Object.defineProperty(FakeImage.prototype,'src',{set(){this.naturalWidth=640;this.naturalHeight=480;this.onload();}});
  const ctx={window:{},navigator:{},document,FileReader:FakeFileReader,Image:FakeImage,localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async()=>({ok:true,json:async()=>({})}),console};
  vm.runInNewContext(generated,ctx);
  const picked=await ctx.window.ForgeHost.files.pick({accept:'image/*,text/*',multiple:true});
  assert.equal(picked.length,2);
  assert.equal(picked[0].name,'one.jpg');
  assert.equal(picked[0].base64,'QUJD');
  assert.equal(picked[1].dataUrl,'data:text/plain;base64,VEVTVA==');
  assert.equal(inputs[0].accept,'image/*,text/*');
  assert.equal(inputs[0].multiple,true);
  assert.equal(children.length,0,'temporary browser inputs must be removed after selection');
  const gallery=await ctx.window.ForgeHost.camera.pickPhoto({quality:85});
  assert.equal(gallery.name,'gallery.png');
  assert.equal(gallery.width,640);
  assert.equal(inputs[1].accept,'image/*');
  assert.equal(inputs[1].capture,'','gallery picker should not force camera capture');
  const shot=await ctx.window.ForgeHost.camera.takePhoto({facing:'front'});
  assert.equal(shot.name,'capture.jpg');
  assert.equal(shot.base64,'SE9U');
  assert.equal(inputs[2].capture,'user');
  const direct=await ctx.window.ForgeHost.files.pick({accept:'video/*',inline:false,maxBytes:100});
  assert.equal(direct.file.name,'video.mp4');
  assert.equal(direct.inline,false);
  assert.equal(direct.base64,undefined,'direct file mode avoids base64 duplication');
  assert.equal(inputs[3].accept,'video/*');
  await assert.rejects(()=>ctx.window.ForgeHost.files.pick({inline:false,maxBytes:100}),/exceeds the 100-byte limit/);
  assert.equal(children.length,0,'direct and rejected file inputs must be removed');
  assert.equal((await ctx.window.ForgeHost.camera.isAvailable()).available,true);
  assert.equal((await ctx.window.ForgeHost.camera.requestPermission()).promptOnUse,true);
  assert.equal((await ctx.window.ForgeHost.getCapabilities()).camera,true);
  assert.equal(children.length,0);
}

async function exerciseChatAttachments() {
  let openAiBody=null,openAiCalls=0;
  const oaiSource=api.buildStandaloneRuntimeSource(app,providerData,[{id:'openai',key:'image-chat-key'}]);
  const oaiCtx={window:{prompt(){throw new Error('embedded key should not prompt');}},navigator:{},document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}};}},localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async function(url,init){openAiCalls++;openAiBody=JSON.parse(init.body);return {ok:true,json:async()=>({choices:[{message:{content:'image understood'}}]})};},console};
  vm.runInNewContext(oaiSource,oaiCtx);
  const oaiResult=await oaiCtx.window.ForgeHost.ai.chat({prompt:'Describe this picture',attachments:[{name:'photo.jpg',mime:'image/jpeg',dataUrl:'data:image/jpeg;base64,QUJD'},{name:'notes.txt',mime:'text/plain',text:'blue car'}]});
  assert.equal(oaiResult.content,'image understood');
  assert.equal(openAiCalls,1);
  const oaiContent=openAiBody.messages[0].content;
  assert.equal(oaiContent[0].text,'Describe this picture');
  assert.deepEqual(oaiContent[1],{type:'image_url',image_url:{url:'data:image/jpeg;base64,QUJD'}});
  assert.match(oaiContent[2].text,/blue car/);
  await assert.rejects(oaiCtx.window.ForgeHost.ai.chat({prompt:'read',attachments:[{name:'doc.pdf',mime:'application/pdf',base64:'JVBERi0='}]}),/needs Forge or a Gemini provider/);
  assert.equal(openAiCalls,1,'unsupported binary file should fail before network fetch');

  let geminiBody=null;
  const geminiData={selectedProvider:'gemini',providers:[{id:'gemini',label:'Gemini',base:'https://generativelanguage.googleapis.com/v1beta',model:'gemini-2.5-flash',auth:'query',kind:'gemini',key:''}]};
  const geminiSource=api.buildStandaloneRuntimeSource(app,geminiData,[{id:'gemini',key:'gemini-file-key'}]);
  const geminiCtx={window:{prompt(){throw new Error('embedded key should not prompt');}},navigator:{},document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}};}},localStorage:{getItem(){return null;},setItem(){},removeItem(){}},fetch:async function(url,init){geminiBody=JSON.parse(init.body);return {ok:true,json:async()=>({candidates:[{content:{parts:[{text:'gemini read'}]}}]})};},console};
  vm.runInNewContext(geminiSource,geminiCtx);
  const geminiResult=await geminiCtx.window.ForgeHost.ai.chat({prompt:'Read these',attachments:[{name:'photo.png',mime:'image/png',dataUrl:'data:image/png;base64,UE5H'},{name:'report.pdf',mime:'application/pdf',base64:'JVBERi0='}]});
  assert.equal(geminiResult.content,'gemini read');
  const geminiParts=geminiBody.contents[0].parts;
  assert.equal(geminiParts[0].text,'Read these');
  assert.deepEqual(geminiParts[1],{inline_data:{mime_type:'image/png',data:'UE5H'}});
  assert.deepEqual(geminiParts[2],{inline_data:{mime_type:'application/pdf',data:'JVBERi0='}});
}

async function exerciseAzureStandaloneChat() {
  const azureData = {
    selectedProvider:'azure',
    providers:[{id:'azure',label:'Azure',base:'',model:'deploy-1',auth:'api-key',kind:'openai',azure:true,azureResource:'forge-test',deployment:'deploy-1',apiVersion:'2024-06-01',key:''}],
  };
  const generated=api.buildStandaloneRuntimeSource(app,azureData,[{id:'azure',key:'azure-selected-key'}]);
  let requestUrl='', requestInit=null;
  const ctx={
    window:{prompt(){throw new Error('embedded key should not prompt');}}, navigator:{},
    document:{readyState:'complete',body:{appendChild(){}},getElementById(){return null;},createElement(){return {style:{},remove(){}}; }},

    localStorage:{getItem(){return null;},setItem(){},removeItem(){}},
    fetch:async function(url,init){requestUrl=url;requestInit=init;return {ok:true,json:async()=>({choices:[{message:{content:'azure ok'}}]})};}, console,
  };
  vm.runInNewContext(generated,ctx);
  const result=await ctx.window.ForgeHost.ai.chat({prompt:'hello'});
  assert.equal(result.content,'azure ok');
  assert.equal(requestUrl,'https://forge-test.openai.azure.com/openai/deployments/deploy-1/chat/completions?api-version=2024-06-01');
  assert.equal(requestInit.headers['api-key'],'azure-selected-key');
}

async function exerciseStandaloneChat(selectedKeys, expectedKey, expectPrompt) {
  const generated = api.buildStandaloneRuntimeSource(app, providerData, selectedKeys);
  const persisted = new Map();
  let prompts = 0;
  let requestInit = null;
  const runtime = {
    window: { prompt(){ prompts++; return 'recipient-session-key'; } },
    navigator: {},
    document: { readyState:'complete', body:{appendChild(){}}, getElementById(){return null;}, createElement(){return {style:{},click(){}};} },
    localStorage: { getItem(k){return persisted.has(k)?persisted.get(k):null;}, setItem(k,v){persisted.set(k,v);}, removeItem(k){persisted.delete(k);} },
    fetch: async function(_url, init){ requestInit=init; return {ok:true,json:async()=>({choices:[{message:{content:'hello'}}],model:'test-model'})}; },
    console,
  };
  runtime.window.document=runtime.document;
  vm.runInNewContext(generated, runtime);
  const result=await runtime.window.ForgeHost.ai.chat({prompt:'hi'});
  assert.equal(result.content,'hello');
  assert.equal(requestInit.headers.Authorization,'Bearer '+expectedKey);
  const agentRounds=[];
  const agentResult=await runtime.window.ForgeHost.ai.agent({messages:[
    {role:'user',content:'agent question'},
    {role:'tool',name:'web_search',content:'previous tool output'},
  ],onRound(event){agentRounds.push(event.round);}});
  assert.equal(agentResult.content,'hello');
  assert.equal(agentResult.toolsUnavailable,true);
  assert.equal(agentResult.toolMode,'chat-only');
  assert.deepEqual(agentRounds,[1]);
  const agentBody=JSON.parse(requestInit.body);
  assert.equal(agentBody.messages[1].role,'user');
  assert.match(agentBody.messages[1].content,/Tool result \(web_search\)/);
  assert.equal(prompts,expectPrompt?1:0);
  assert.equal(Array.from(persisted.values()).some(v=>String(v).includes('recipient-session-key')),false,'recipient key must not be persisted');
}

async function exerciseForgeChatServerRuntime() {
  const generated = api.buildStandaloneRuntimeSource(app, Object.assign({},providerData,{selectedProvider:'xai'}), [{id:'openai',key:'DO-NOT-SHIP'}], {mode:'forgechat',apiBase:'/forgechat'});
  const persisted = new Map();
  const calls = [];
  let streamStarted;
  const streamStartedPromise = new Promise(resolve=>{streamStarted=resolve;});
  const agentDialogs=[];
  let nativeConfirmCalls=0;
  let context;
  function fakeElement(tag){return {tag,style:{},attributes:{},children:[],setAttribute(key,value){this.attributes[key]=value;},appendChild(child){this.children.push(child);child.parentNode=this;return child;},focus(){}};}
  const fakeBody={children:[],appendChild(node){this.children.push(node);node.parentNode=this;if(node.attributes&&node.attributes['aria-modal']==='true'){const panel=node.children[0],buttons=panel.children[2].children;agentDialogs.push({title:panel.children[0].textContent,message:panel.children[1].textContent});const approved=context.window.nextAgentApproval!==false;context.window.nextAgentApproval=undefined;buttons[approved?1:0].onclick();}},removeChild(node){const index=this.children.indexOf(node);if(index>=0)this.children.splice(index,1);node.parentNode=null;}};
  context = {
    window:{location:{origin:'https://forge.example.test',protocol:'https:',pathname:'/forgechat/apps/demo',href:'https://forge.example.test/forgechat/apps/demo'},confirm(){nativeConfirmCalls++;return true;}},

    navigator:{},
    document:{readyState:'complete',body:fakeBody,getElementById(){return null;},createElement(tag){return fakeElement(tag);}},
    URL, TextDecoder, AbortController, Blob, btoa, atob,
    localStorage:{getItem(key){return persisted.has(key)?JSON.stringify(persisted.get(key)):null;},setItem(key,value){persisted.set(key,JSON.parse(value));},removeItem(key){persisted.delete(key);}},
    fetch:async function(url,init){
      calls.push({url:String(url),init:init});
      if(String(url).endsWith('/api/v1/providers'))return {ok:true,status:200,json:async()=>({providers:[{id:'ollama',label:'Local Ollama',kind:'openai',model:'qwen3:0.6b',available:true,imageModels:[]},{id:'xai',label:'xAI',kind:'openai',model:'grok-3',available:true,imageModels:['grok-imagine-image']}],selectedId:'ollama',defaultId:'ollama'})};
      if(String(url).endsWith('/api/v1/chat/stream')){
        const prompt=JSON.parse(init.body).messages[0].content;
        if(prompt==='cancel'){streamStarted(init.signal);return new Promise((resolve,reject)=>init.signal.addEventListener('abort',()=>reject(new Error('aborted')),{once:true}));}
        const chunks=['data: {"type":"delta","content":"server "}\n\n','data: {"type":"delta","content":"answer"}\n\n','data: {"type":"done"}\n\n'];
        let index=0;
        return {ok:true,status:200,body:{getReader(){return {async read(){return index<chunks.length?{value:new TextEncoder().encode(chunks[index++]),done:false}:{done:true};},async cancel(){}};}}};
      }
      if(String(url).endsWith('/api/v1/chat'))return {ok:true,status:200,json:async()=>({ok:true,content:'server answer',text:'server answer',providerId:'ollama',model:'qwen3:0.6b'})};
      if(String(url).endsWith('/api/v1/transcribe'))return {ok:true,status:200,json:async()=>({text:'recognized speech',segments:[{start:0,end:1.2,text:'recognized speech'}],providerId:'xai'})};
      if(String(url).endsWith('/api/v1/images/generate'))return {ok:true,status:200,json:async()=>({ok:true,providerId:'xai',model:'grok-imagine-image',count:1,images:[{url:'https://cdn.example/image.png'}]})};
      if(String(url).includes('/api/v1/tts/voices')){const local=String(url).includes('engine=local');return {ok:true,status:200,json:async()=>({available:true,providerId:local?'vm-local':'xai',engine:local?'local':'xai',voices:[{id:local?'en-us':'eve',name:local?'English':'eve',label:local?'English (en-us)':'eve',locale:local?'en-us':'en'}]})};}
      if(String(url).endsWith('/api/v1/tts/synthesize-to-agent')){const body=JSON.parse(init.body),local=body.engine==='local';return {ok:true,status:200,json:async()=>({ok:true,agentPath:body.destination,mime:local?'audio/wav':'audio/mpeg',size:8})};}
      if(String(url).endsWith('/api/v1/tts/synthesize')){const local=JSON.parse(init.body).engine==='local';return {ok:true,status:200,headers:{get(name){return name==='X-Forge-TTS-Engine'?(local?'local':'xai'):null;}},blob:async()=>new Blob([local?'WAV-DATA':'MP3-DATA'],{type:local?'audio/wav':'audio/mpeg'})};}
      if(String(url).endsWith('/api/v1/agent/status'))return {ok:true,status:200,json:async()=>({ok:true,version:'1.0.0'})};
      if(String(url).endsWith('/api/v1/agent/exec'))return {ok:true,status:200,json:async()=>({ok:true,stdout:'agent result',exitCode:0,id:'job-1'})};
      if(String(url).includes('/api/v1/agent/files?path='))return {ok:true,status:200,blob:async()=>new Blob(['agent file'],{type:'text/plain'})};
      if(String(url).includes('/api/v1/agent/files?destination='))return {ok:true,status:200,json:async()=>({ok:true,path:'fs/out.txt',bytes:5,sha256:'abc'})};
      throw new Error('unexpected endpoint');
    },
    console,
  };
  vm.runInNewContext(generated,context);
  const available=await context.window.ForgeHost.ai.isAvailable();
  assert.equal(available.available,true);
  assert.equal(available.providers[0].needsKey,false);
  assert.equal(calls[0].init.headers['X-ForgeChat-App'],'demo');
  let delta='';
  const result=await context.window.ForgeHost.ai.chatStream({prompt:'hello',onDelta(value,meta){if(!meta.done)delta+=value;}});
  assert.equal(result.content,'server answer');
  assert.equal(delta,'server answer');
  const chatCall=calls.find(call=>call.url.endsWith('/api/v1/chat/stream'));
  assert.ok(chatCall);
  assert.equal(chatCall.init.credentials,'same-origin');
  assert.equal(chatCall.init.headers['Content-Type'],'application/json');
  assert.equal(chatCall.init.headers['X-ForgeChat-App'],'demo');
  const body=JSON.parse(chatCall.init.body);
  assert.equal(body.providerId,'ollama');
  assert.equal(body.model,'qwen3:0.6b');
  assert.equal(body.messages[0].content,'hello');
  assert.ok(!chatCall.init.body.includes('DO-NOT-SHIP'));
  await context.window.ForgeHost.ai.chat({prompt:'describe this',attachments:[{type:'image',mime:'image/png',dataUrl:'data:image/png;base64,aGVsbG8='},{type:'text',name:'notes.txt',mime:'text/plain',text:'keep it concise'}]});
  const agentRounds=[];
  const agentResult=await context.window.ForgeHost.ai.agent({messages:[
    {role:'user',content:'agent hello'},
    {role:'assistant',content:null,tool_calls:[{id:'call-1'}]},
    {role:'tool',name:'web_search',content:'tool result'},
  ],tools:{preset:'safe'},onRound(event){agentRounds.push(event.round);}});
  assert.equal(agentResult.content,'server answer');
  assert.equal(agentResult.toolMode,'chat-only');
  assert.equal(agentResult.toolsUnavailable,true);
  assert.deepEqual(agentRounds,[1]);
  const agentCalls=calls.filter(call=>call.url.endsWith('/api/v1/chat/stream'));
  const agentCall=agentCalls[agentCalls.length-1];
  assert.ok(agentCall);
  const agentBody=JSON.parse(agentCall.init.body);
  assert.equal(agentBody.messages[0].content,'agent hello');
  assert.equal(agentBody.messages[2].role,'user','prior host tool output is preserved as untrusted plain text');
  assert.match(agentBody.messages[2].content,/Tool result \(web_search\)/);
  assert.equal(Object.hasOwn(agentBody,'tools'),false,'host tool schemas must not be sent to the chat server');
  assert.ok(agentBody.messages.every(message=>Object.keys(message).every(key=>key==='role'||key==='content')));
  const attachmentCall=calls.find(call=>call.url.endsWith('/api/v1/chat'));
  assert.ok(attachmentCall);
  assert.equal(attachmentCall.init.credentials,'same-origin');
  const attachmentMessages=JSON.parse(attachmentCall.init.body).messages;
  assert.equal(attachmentMessages[0].content[1].image_url.url,'data:image/png;base64,aGVsbG8=');
  assert.equal(attachmentMessages[0].content[2].text,'keep it concise');
  const toolList=await context.window.ForgeHost.tools.list();
  assert.equal(toolList.count,1);
  const imageResult=await context.window.ForgeHost.tools.run('image_generate',{prompt:'a green fox',model:'grok-imagine-image'});
  assert.equal(imageResult.images[0].url,'https://cdn.example/image.png');
  const imageCall=calls.find(call=>call.url.endsWith('/api/v1/images/generate'));
  assert.ok(imageCall);
  assert.equal(imageCall.init.headers['X-ForgeChat-App'],'demo');
  assert.equal(JSON.parse(imageCall.init.body).providerId,'xai');
  assert.equal(imageCall.init.body.includes('DO-NOT-SHIP'),false);
  const nativeConfirmBeforeAgent=nativeConfirmCalls;
  const transcription=await context.window.ForgeHost.ai.transcribe({dataUrl:'data:audio/mpeg;base64,YXVkaW8=',language:'en',timestamps:true,prompt:'subtitle timing'});
  assert.equal(transcription.text,'recognized speech');
  const transcriptionCall=calls.find(call=>call.url.endsWith('/api/v1/transcribe'));
  assert.ok(transcriptionCall);
  assert.equal(transcriptionCall.init.credentials,'same-origin');
  assert.equal(transcriptionCall.init.headers['X-ForgeChat-App'],'demo');
  const transcriptionBody=JSON.parse(transcriptionCall.init.body);
  assert.equal(transcriptionBody.dataUrl,'data:audio/mpeg;base64,YXVkaW8=');
  assert.equal(transcriptionBody.timestamps,true);
  assert.equal(transcriptionBody.providerId,'ollama');
  context.window.nextAgentApproval=false;
  await assert.rejects(()=>context.window.ForgeHost.ai.transcribe({dataUrl:'data:audio/mpeg;base64,Y2FuY2Vs'}),/canceled/);
  assert.equal(calls.filter(call=>call.url.endsWith('/api/v1/transcribe')).length,1,'unapproved audio never reaches the transcription provider');
  context.window.nextAgentApproval=true;
  const agentAvailable=await context.window.ForgeHost.termux.isAvailable();
  assert.equal(agentAvailable.available,true);
  const commandResult=await context.window.ForgeHost.termux.exec({script:'echo trusted job',timeoutMs:5000});
  assert.equal(commandResult.bridge,'backend-agent');
  const commandCall=calls.find(call=>call.url.endsWith('/api/v1/agent/exec'));
  assert.ok(commandCall);
  assert.equal(commandCall.init.credentials,'same-origin');
  assert.equal(commandCall.init.headers['X-ForgeChat-App'],'demo');
  assert.equal(JSON.parse(commandCall.init.body).script,'echo trusted job');
  context.window.nextAgentApproval=false;
  await assert.rejects(()=>context.window.ForgeHost.termux.exec({script:'echo canceled'}),/canceled/);
  assert.equal(calls.filter(call=>call.url.endsWith('/api/v1/agent/exec')).length,1,'a canceled command never reaches the backend');
  context.window.nextAgentApproval=true;
  const remoteFile=await context.window.ForgeHost.termux.readFile({path:'fs/notes.txt',mime:'text/plain'});
  assert.equal(remoteFile.bridge,'backend-agent');
  assert.equal(remoteFile.base64,btoa('agent file'));
  const uploaded=await context.window.ForgeHost.termux.writeFile({destination:'fs/out.txt',content:'hello',mime:'text/plain'});
  assert.equal(uploaded.bridge,'backend-agent');
  const browserVideo=new Blob(['video bytes'],{type:'video/mp4'});
  const videoUpload=await context.window.ForgeHost.termux.writeFile({destination:'videolingo_test/input.mp4',file:browserVideo,mime:'video/mp4',overwrite:true});
  assert.equal(videoUpload.bridge,'backend-agent');
  const browserUploadCall=calls.find(call=>call.url.includes('destination=videolingo_test'));
  assert.equal(browserUploadCall.init.method,'PUT');
  assert.equal(browserUploadCall.init.body,browserVideo,'browser File/Blob is streamed directly without base64 duplication');
  const voices=await context.window.ForgeHost.tts.getVoices();
  assert.equal(voices.voices[0].id,'eve');
  assert.deepEqual(voices.options.map(option=>option.value),['eve']);
  assert.deepEqual(voices.ids,['eve']);
  assert.equal((await context.window.ForgeHost.ai.listVoices({providerId:'xai'})).engine,'xai');
  context.window.nextAgentApproval=false;
  await assert.rejects(()=>context.window.ForgeHost.ai.tts({text:'Canceled synthesis',play:false}),/canceled/);
  assert.equal(calls.filter(call=>call.url.endsWith('/api/v1/tts/synthesize')).length,0,'canceled TTS text is never sent');
  assert.equal(agentDialogs.at(-1).title,'Review request');
  context.window.nextAgentApproval=true;
  const ttsFile=await context.window.ForgeHost.tts.synthesizeToFile({text:'A subtitle',path:'/sdcard/Download/Forge/Staging/speech.wav',voice:'eve'});
  assert.match(ttsFile.agentPath,/^tts\/.*\.wav$/);
  const ttsFileCall=calls.find(call=>call.url.endsWith('/api/v1/tts/synthesize-to-agent'));
  assert.ok(ttsFileCall);
  assert.equal(JSON.parse(ttsFileCall.init.body).text,'A subtitle');
  assert.equal(JSON.parse(ttsFileCall.init.body).format,'wav');
  assert.match(JSON.parse(ttsFileCall.init.body).destination,/^tts\//);
  const cloudTts=await context.window.ForgeHost.ai.ttsToFile({text:'Cloud subtitle',providerId:'xai',path:'/sdcard/Download/speech.mp3'});
  assert.match(cloudTts.agentPath,/^tts\/.*\.mp3$/);
  const localAvailable=await context.window.ForgeHost.tts.isAvailable({engine:'local'});
  assert.equal(localAvailable.available,true);
  assert.equal(localAvailable.engine,'local');
  const localVoices=await context.window.ForgeHost.tts.getVoices({engine:'local'});
  assert.equal(localVoices.engine,'local');
  assert.deepEqual(localVoices.ids,['en-us']);
  const localFile=await context.window.ForgeHost.tts.synthesizeToFile({engine:'local',text:'No provider call',path:'/tmp/local.mp3',voice:'en-us'});
  assert.match(localFile.agentPath,/^tts\/.*\.wav$/);
  assert.match(agentDialogs.at(-1).message,/offline eSpeak NG engine/);
  assert.match(JSON.parse(calls.filter(call=>call.url.endsWith('/api/v1/tts/synthesize-to-agent')).at(-1).init.body).engine,/^local$/);
  const localAgentRequest=JSON.parse(calls.filter(call=>call.url.endsWith('/api/v1/tts/synthesize-to-agent')).at(-1).init.body);
  assert.equal(localAgentRequest.format,'wav');
  assert.equal(localAgentRequest.engine,'local');
  assert.equal(Object.hasOwn(localAgentRequest,'providerId'),false);
  const localAudio=await context.window.ForgeHost.ai.tts({engine:'local',text:'Local speech',play:false,returnAudio:true});
  assert.equal(localAudio.mime,'audio/wav');
  assert.equal(JSON.parse(calls.filter(call=>call.url.endsWith('/api/v1/tts/synthesize')).at(-1).init.body).engine,'local');
  assert.equal(nativeConfirmCalls,nativeConfirmBeforeAgent,'backend-agent approvals use the in-page dialog, not suppressible native confirms');
  assert.ok(agentDialogs.some(dialog=>dialog.message.includes('Run this command in the private Linux backend agent')));
  const spoken=await context.window.ForgeHost.ai.tts({text:'Hello',play:false,returnAudio:true});
  assert.equal(spoken.mime,'audio/mpeg');
  assert.equal(spoken.base64,btoa('MP3-DATA'));
  assert.equal(context.window.ForgeHost.getCapabilities && (await context.window.ForgeHost.getCapabilities()).tts,true);
  const uploadCall=calls.find(call=>call.url.includes('/api/v1/agent/files?destination='));
  assert.equal(uploadCall.init.method,'PUT');
  assert.equal(uploadCall.init.body instanceof Blob,true);
  assert.equal(uploadCall.init.credentials,'same-origin');
  await assert.rejects(()=>context.window.ForgeHost.ai.configure({apiKey:'forbidden'}),/managed by the ForgeChat server/);
  const pending=context.window.ForgeHost.ai.chatStream({id:'cancel-me',prompt:'cancel'});
  const signal=await streamStartedPromise;
  const cancelled=await context.window.ForgeHost.ai.cancel('cancel-me');
  assert.equal(cancelled.cancelled,true);
  assert.equal(signal.aborted,true);
  await assert.rejects(()=>pending,/cancelled/);
}

(async function(){
  await exerciseForgeChatServerRuntime();
  console.log('✓ ForgeChat runtime calls authenticated same-origin server without exporting keys');
  await exerciseStandaloneChat([], 'recipient-session-key', true);
  console.log('✓ no-secret export prompts for a key and keeps it session-only');
  await exerciseStandaloneImageTool();
  console.log('✓ embedded-key tools.run image_generate sends confirmed request and returns images');
  await exerciseXaiOnlySelection();
  console.log('✓ xAI-only export overrides a stale keyless Cheaper Inference selection without prompting');
  await exerciseImageFallbackAndNoPrompt();
  console.log('✓ image generation tries exported keys before prompting and falls back from Cheaper Inference to xAI');
  await exerciseBrowserMediaPickers();
  console.log('✓ standalone file picker and browser camera/gallery capture APIs return attachment data');
  await exerciseLiveBrowserCameraCapture();
  console.log('✓ standalone live camera shutter captures a photo and sends it as a chat attachment');
  await exerciseChatAttachments();
  console.log('✓ standalone chat sends browser image/text attachments and Gemini inline files');
  await exerciseAzureStandaloneChat();
  console.log('✓ Azure embedded-key export uses resource/deployment URL and api-key auth');
  await exerciseChatCorsDiagnostic();
  console.log('✓ failed browser fetch reports actionable CORS/file-origin guidance');
  await exerciseStandaloneChat([{id:'openai',key:'explicitly-selected-key'}], 'explicitly-selected-key', false);
  console.log('✓ explicitly selected embedded key is used without prompting');
  console.log('\n' + (passed + 11) + ' tests passed.');
})().catch(error=>{console.error(error);process.exitCode=1;});
