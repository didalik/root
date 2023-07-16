#!/usr/bin/env node

import crypto from 'node:crypto' // {{{1
import fetch from 'node-fetch'
import { Run, } from '../lib/run.mjs'

global.fetch = fetch
global.window = {
  CFW_URL_DEV: 'http://127.0.0.1:8787',
  crypto, // now window.crypto can be used in both browser and node
  isNode: true,
}

switch (process.argv[2]) { // {{{1
  case 'debug': // {{{2
    {
      let remote = process.argv[3]
      let noget = process.argv[4]
      console.log('- debug', await new Run().debug(remote, noget))
      break
    }

  case 'generate_keypair': // {{{2
    console.log(await new Run().generate_keypair())
    break

  case 'init_CFW_DO': // {{{2
    {
    let remote = process.argv[3]
    let noget = process.argv[4]
    console.log('- init_CFW_DO', await new Run().init_CFW_DO(remote, noget))
    break
    }

  case 'share_svc': // {{{2
    {
    let remote = process.argv[3]
    let noget = process.argv[4]
    console.log(await new Run().share_svc(remote, noget))
    break
    }

  case 'svc': // {{{2
    {
      let svcRequestPath = process.argv[3]
      let remote = process.argv[4]
      let noget = process.argv[5]
      console.log(await new Run().svc(svcRequestPath, remote, noget))
      break
    }

  default: // {{{2
    throw new Error(`- invalid ${process.argv[2]}`);

  // }}}2
}

