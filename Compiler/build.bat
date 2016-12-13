python build.py --include sea --include sea_deflate --include sea_legacy --output ../Build/Three.JS/sea3d.js
python build.py --include sea --include sea_deflate --include sea_legacy --minify --output ../Build/Three.JS/sea3d.min.js

python build.py --include sea --output ../Build/Three.JS/sea3d.tjs.js
python build.py --include sea --minify --output ../Build/Three.JS/sea3d.tjs.min.js

python build.py --nocheckvars --include sea_physics --output ../Build/Three.JS/sea3d.physics.js
python build.py --nocheckvars --include sea_physics --minify --output ../Build/Three.JS/sea3d.physics.min.js

python build.py --nocheckvars --include sea_o3dgc --output ../Build/Three.JS/sea3d.o3dg.js
python build.py --nocheckvars --include sea_o3dgc --minify --output ../Build/Three.JS/sea3d.o3dg.min.js
