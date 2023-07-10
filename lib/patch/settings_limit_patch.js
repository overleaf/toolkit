/* eslint-disable import/no-absolute-path */
const Path = require('path')
const base = require('/overleaf/services/web/config/settings.overrides.server-pro')
const settings = require('/etc/sharelatex/settings.js')

settings.imageRoot = 'quay.io/sharelatex'

// TeX Live Images
// -----------
//
if (process.env.SANDBOXED_COMPILES === 'true') {
  let allTexLiveDockerImages
  if (process.env.ALL_TEX_LIVE_DOCKER_IMAGES != null) {
    allTexLiveDockerImages = process.env.ALL_TEX_LIVE_DOCKER_IMAGES.split(',')
  }

  let allTexLiveDockerImageNames
  if (process.env.ALL_TEX_LIVE_DOCKER_IMAGE_NAMES != null) {
    allTexLiveDockerImageNames =
      process.env.ALL_TEX_LIVE_DOCKER_IMAGE_NAMES.split(',')
  }

  if (allTexLiveDockerImages != null) {
    settings.allowedImageNames = []
    for (let index = 0; index < allTexLiveDockerImages.length; index++) {
      const fullImageName = allTexLiveDockerImages[index]
      const imageName = Path.basename(fullImageName)
      const imageDesc =
        allTexLiveDockerImageNames != null
          ? allTexLiveDockerImageNames[index]
          : imageName
      settings.allowedImageNames.push({ imageName, imageDesc })
    }
  }
}

settings.maxUploadSize = parseInt(process.env.MAX_FILE_UPLOAD_SIZE, 10)

module.exports = base.mergeWith(settings)
