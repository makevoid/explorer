
ASSETS_JS_THREEJS = %w(
  vendor/three.js
  vendor/three.flycontrols.js
  vendor/three.orbitcontrols.js
  vendor/threex.domevent.js
  vendor/threex.dynamictexture.js
  vendor/qrcode.js
)

ASSETS_JS_DEV = if APP_ENV == "production"
  []
else
  ASSETS_JS_THREEJS
end

ASSETS_JS = %w(
  vendor/jquery.js
  vendor/underscore.js
  vendor/underscore.string.js
  vendor/handlebars.js
  vendor/moment.js
  blocks.js
) + ASSETS_JS_DEV
