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
  assert.match(html, /chooseStandaloneExport\(app\)/);
  assert.match(html, /mode:'standalone',keys:\[\]/);
  assert.doesNotMatch(html, /Export Forge HTML|data-action="forge"|mode:'forge'/);
  assert.match(html, /Export standalone · no keys/);
  assert.match(html, /Embed selected keys &amp; export/);
  assert.match(html, /standalone-export-panel/);
  assert.match(html, /standalone-export-actions/);
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

test('export runtime exposes browser APIs and clearly rejects Forge-only agent APIs', () => {
  assert.match(source, /chat: chat/);
  assert.match(source, /chatStream: async function/);
  assert.match(source, /var tools = \{/);
  assert.match(source, /run: async function\(nameOrOpts, args\)/);
  assert.match(source, /image_generate/);
  assert.match(source, /CORS\/network restriction/);
  assert.match(source, /ai\.agent \(host-managed tools are Forge-only\)/);
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
  assert.match(exportDocs,/capture` hint/);
  assert.match(exportDocs,/host-managed `ForgeHost\.ai\.agent\(\)`/);
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

async function exerciseBrowserMediaPickers() {
  const generated=api.buildStandaloneRuntimeSource(app,providerData,[]);
  const queued=[
    {name:'one.jpg',type:'image/jpeg',size:7,dataUrl:'data:image/jpeg;base64,QUJD'},
    {name:'two.txt',type:'text/plain',size:4,dataUrl:'data:text/plain;base64,VEVTVA=='},
    {name:'gallery.png',type:'image/png',size:5,dataUrl:'data:image/png;base64,UE5H'},
    {name:'capture.jpg',type:'image/jpeg',size:6,dataUrl:'data:image/jpeg;base64,SE9U'},
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
  assert.equal(prompts,expectPrompt?1:0);
  assert.equal(Array.from(persisted.values()).some(v=>String(v).includes('recipient-session-key')),false,'recipient key must not be persisted');
}

(async function(){
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
  await exerciseChatAttachments();
  console.log('✓ standalone chat sends browser image/text attachments and Gemini inline files');
  await exerciseAzureStandaloneChat();
  console.log('✓ Azure embedded-key export uses resource/deployment URL and api-key auth');
  await exerciseChatCorsDiagnostic();
  console.log('✓ failed browser fetch reports actionable CORS/file-origin guidance');
  await exerciseStandaloneChat([{id:'openai',key:'explicitly-selected-key'}], 'explicitly-selected-key', false);
  console.log('✓ explicitly selected embedded key is used without prompting');
  console.log('\n' + (passed + 8) + ' tests passed.');
})().catch(error=>{console.error(error);process.exitCode=1;});
