import { algorithm, base64ToUint8, pGET, sign, uint8ToBase64, } from '../../public/lib/util.mjs' // {{{1

class Run { // {{{1
  constructor () { // {{{2
  }

  async debug (remoteStr, nogetStr) { // {{{2
    let [privateKey, publicKey, host, noget] = await pGET_parms(remoteStr, nogetStr)
    return await pGET(
      '/debug', debug_parms(), { privateKey, publicKey }, host, noget
    );
  }

  async generate_keypair () { // {{{2
    const keypair = await window.crypto.subtle.generateKey(
      algorithm, true, ['sign', 'verify']
    )
    let pk = await window.crypto.subtle.exportKey('raw', keypair.publicKey)
    let sk = await window.crypto.subtle.exportKey('jwk', keypair.privateKey)
    pk = uint8ToBase64(new Uint8Array(pk))
    sk = JSON.stringify(sk)
    return `${sk} ${pk}`;
  }

  async init_CFW_DO (remoteStr, nogetStr) { // {{{2
    let [privateKey, publicKey, host, noget] = await pGET_parms(remoteStr, nogetStr)
    return await pGET(
      '/init_CFW_DO', init_CFW_DO_parms(), { privateKey, publicKey }, host, noget
    );
  }

  async share_svc (remoteStr, nogetStr) { // {{{2
    let [privateKey, publicKey, host, noget] = await pGET_parms(remoteStr, nogetStr)
    return await pGET(
      '/share_svc', share_svc_parms(), { privateKey, publicKey }, host, noget
    );
  }

  async svc (svcRequestPath, remoteStr, nogetStr) { // {{{2
    let [privateKey, publicKey, host, noget] = await pGET_parms(remoteStr, nogetStr)
    return await pGET(
      '/svc/' + svcRequestPath, svc_parms(svcRequestPath), 
      { privateKey, publicKey }, host, noget
    );
  }

  // }}}2
}

function debug_parms (e = process.env) { // {{{1
  let result = ''
  let i = 0, key = ['SVC_START', 'SVC_PK', 'SVC_NAME', 'SVC_URL']
  for (let p of [e.SVC_START, e.SVC_PK, e.SVC_NAME, e.SVC_URL]) {
    result += `${key[i++]}=${encodeURIComponent(p)}&`
  }
  return '?' + result.slice(0, result.length - 1);
}

function init_CFW_DO_parms (e = process.env) { // {{{1
  let result = ''
  let i = 0, key = ['SVC_START', 'SVC_PK', 'SVC_NAME', 'SVC_URL']
  for (let p of [e.SVC_START, e.SVC_PK, e.SVC_NAME, e.SVC_URL]) {
    result += `${key[i++]}=${encodeURIComponent(p)}&`
  }
  return '?' + result.slice(0, result.length - 1);
}

async function pGET_parms (remote, noget, e = process.env) { // {{{1
  let a = base64ToUint8(e.OWNER_PK)
  let publicKey = await window.crypto.subtle.importKey(
    'raw', a.buffer, algorithm, true, ['verify']
  )
  a = JSON.parse(e.OWNER_SK)
  let privateKey = await window.crypto.subtle.importKey(
    'jwk', a, algorithm, true, ['sign']
  )
  let host = remote == 'remote' ? `https://svc-${e.SVC_NAME}.didalik.workers.dev`
  : `http://127.0.0.1:${e['PORT_' + e.SVC_NAME] ?? 8787}`
  noget = noget == 'noget';
  return [privateKey, publicKey, host, noget];
}

function share_svc_parms (e = process.env) { // {{{1
  let result = ''
  let i = 0, key = ['SVC_START', 'SVC_PK', 'SVC_NAME', 'SVC_URL', 'SVC_COMMIT_ID']
  for (let p of [e.SVC_START, e.SVC_PK, e.SVC_NAME, e.SVC_URL, e.SVC_COMMIT_ID]) {
    result += `${key[i++]}=${encodeURIComponent(p)}&`
  }
  return '?' + result.slice(0, result.length - 1);
}

function svc_parms (path, e = process.env) { // {{{1
  if (path == 'list') {
    return '';
  }
  let result = ''
  let i = 0, key = ['SVC_PK']
  for (let p of [e.SVC_PK]) {
    result += `${key[i++]}=${encodeURIComponent(p)}&`
  }
  return '?' + result.slice(0, result.length - 1);
}

export { Run, } // {{{1

