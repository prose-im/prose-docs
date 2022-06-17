# prose-docs

[![Build and Deploy](https://github.com/prose-im/prose-docs/workflows/Build%20and%20Deploy/badge.svg?branch=production)](https://github.com/prose-im/prose-docs/actions/workflows/deploy.yml)

**Prose Technical Docs, used by Prose server administrators.**

Copyright 2022, Prose Foundation.

## Clone Instructions

As this project uses Git LFS to store large files (ie. PNG, JPG and GIF files from guides), it requires Git LFS to be available on the system cloning this repository.

**1. Start with installing Git LFS using Homebrew:**

`brew install git-lfs`

**2. Then, initialize your Git LFS user configuration:**

`git lfs install`

**3. Finally, clone the repository:**

`git clone git@github.com:prose-im/prose-docs.git`

_⚠️ Make sure that the "filtering" step pulling LFS data is executed (10MB+). This step comes after the "objects" pull step._

## Build Setup

Built with [Chappe](https://github.com/crisp-oss/chappe). See the commands below for reference on how to build the docs.

```bash
# install dependencies
$ npm install

# build static assets for production
$ npm run build
```
