'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "a61ae7ba8ac7ff031187f1f2ae73b576",
".git/config": "7d516eb81db39740fbfcc4a6fab527dc",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "3f6343206e637b84d9e70ad2fe757521",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "aba6ee49ebe2c68ee093e6126493504d",
".git/logs/refs/heads/gh-pages": "d0a4e5612581c35c84b135b6fab5346f",
".git/logs/refs/heads/master": "aba6ee49ebe2c68ee093e6126493504d",
".git/logs/refs/remotes/origin/gh-pages": "d5cd52c207b3745156553722807df601",
".git/objects/02/e9c7bfd01ae233714e671afba6097ba6a07593": "b6422e0db6d29b6db1fdd5c01823a282",
".git/objects/08/32d0db2def1613c1c45aa4fe9156a1c6b7d589": "e05df183e5eeaddf39672a2516f9c41d",
".git/objects/0b/dbc3a38234aa71066e6cc9403eeb511aec282e": "8ab9548c0fb8ab04f5bc170e3f165724",
".git/objects/14/e74f608cb4322ef1d255241c4b4de674ab189a": "28d0733c0d20864518d0392d6770395e",
".git/objects/15/139307ea67bac555324d68043b38c9d5280711": "abf3fdefbe065a9829d0dcf60a24cff7",
".git/objects/17/16a0b3acc3934f9276b0212f5166e31590f8db": "54b5752f440ded3caa54aaff9a82efae",
".git/objects/19/9f521daae264ec15742818a5564ecff644ba1e": "890192d6badd44d3b478057d5e5e8fd8",
".git/objects/19/dca7b10422b902bb40bd34866938a0461495f6": "3ec156c0b75c8eb1232996b7e28b6921",
".git/objects/1a/411e85a99f420ea2c6f6ddc9706b201a3ccd63": "cafb954d839d99367413091ab95ca687",
".git/objects/1b/6156e6b026969f568a911319e070a9dc22eb5e": "81528282424913ed2b5cceb55cecc6d7",
".git/objects/1f/45b5bcaac804825befd9117111e700e8fcb782": "7a9d811fd6ce7c7455466153561fb479",
".git/objects/21/f294fa1db74066edecb6f523738750f869b995": "569d0d77c680f5afb292e74f8a5a67a3",
".git/objects/29/4055f6603ba7aa9be76835436a9fa312dd5c6b": "b05533a45319102773662c6ed7702d5c",
".git/objects/2b/558cecfd804836efb901a7a42900eb47d6fed0": "f14c303d174f94bb544f6915ee82b549",
".git/objects/32/aa3cae58a7432051fc105cc91fca4d95d1d011": "4f8558ca16d04c4f28116d3292ae263d",
".git/objects/33/6f420cea058c610d0f2871b823d25b5d26f453": "f5fc49e1a0db2b11e84bfec7ade878a9",
".git/objects/35/a46c1f4b16565005e3d1b843e68f628fcb2646": "a08b930220e2fa85b7322a906c475210",
".git/objects/37/3c4bc31020bd3e16b222c4599eafca3d091dd0": "52b1dba7aa811268b9c7dd55b2b85db3",
".git/objects/39/85f37fab27a12e4372a59d9c4067e6a8aad30a": "6e9fbb9fa0eaf3e64ba3407d22bfc833",
".git/objects/3a/7525f2996a1138fe67d2a0904bf5d214bfd22c": "ab6f2f6356cba61e57d5c10c2e18739d",
".git/objects/40/0d5b186c9951e294699e64671b9dde52c6f6a0": "f6bd3c7f9b239e8898bace6f9a7446b9",
".git/objects/44/a8b8e41b111fcf913a963e318b98e7f6976886": "5014fdb68f6b941b7c134a717a3a2bc6",
".git/objects/48/b95b02942c707a0c58d27d8220612c029d2a22": "c1ff0046fca2a5e928f4e084f5bfbe1c",
".git/objects/49/11e054345ca7368eb656c2291365661e46cd66": "9398f717e86ff7a20211ba5b3bbcd2d9",
".git/objects/49/32ad23d91ae5a0a07e84ee5f0c281d90d8d530": "eabd1be58bd688845b870b637dedf5a2",
".git/objects/4a/14a634ddac88ad1bab9d89fd71d4234e02d1e2": "a99f2515ba0459daaa64b171bf474333",
".git/objects/4e/1cd267220549722fc3298f0d64860abec7c981": "84b2b299d6215857bae137a5fc1fd479",
".git/objects/56/e25098f66d8ef85ecd64be55a5aac1bc2c1903": "475e936284eddb618a3fed5f810fd28f",
".git/objects/57/0bd6d26597f4f34c47030d9245331db37b64b4": "dbd53fde0cc2de62e9615e22c14cac99",
".git/objects/5b/4e928e816bbed7728f0d91b44bab910963a91a": "8fbb598cf3c7e5f30cbfe45e69905b5d",
".git/objects/5c/080fe51e3591d27dbcb0d9e083869d92306d53": "dc11976349a45c21e07d7ba4b510feaa",
".git/objects/5f/d2bca3bb9b0fbb305839dbf900381660d9aa20": "da0c35795ce63d1226302eb330a16ef1",
".git/objects/61/f339e70a53f9c34ec36b9878346c5bd14ab4f0": "f27414992884b537228244512cbf506d",
".git/objects/65/7a3e96916b3d1fa637606a884c302953122a7a": "f9fb996ee2d08c12a4791aab03543363",
".git/objects/66/10588073c09cfcbd6c7620ee5040cfc251cabb": "ad9cc0a43190fb4d7e1ce6a37974fe7b",
".git/objects/66/e018946c1321139ca6c8ed31d53ed38d7343fb": "6408a69fd503a78c395603687a7c8b70",
".git/objects/67/6096c213a3e75aab7627afe0d6a46a35fa56dc": "32c930c9e0838ed77f6b79ce2ff96498",
".git/objects/68/79418d1dad8a652245ec1c8e9ee50600e1c381": "28403b25054e6ea9a81720bb7d729255",
".git/objects/6a/41ce7a9ebe09225f2809f153a906fe7233bf68": "2cd747b8c52b18ac5dd1d9604f37b341",
".git/objects/6a/7a8e5dc3ce9b001a9761ef6197482d271be591": "9ba379eb4310fb7de21623da07102fe7",
".git/objects/6b/e909fbf40b23748412f0ea89bf0fae827ed976": "5f118419157d9534688915220cc803f7",
".git/objects/6f/5609f44413818f1573d5e80797ac44fff87ddf": "703e21cc2c7990b9b56a7540a7e79697",
".git/objects/71/aad807dbc574624fbc67787a817570f078e3c8": "d891f090af18e063a9720ad1df20cf70",
".git/objects/7b/f97ce09a2addc9aa7d9884e67d6f36af3bb87e": "8849f6cd16e0b55ac8d86edd45d13f84",
".git/objects/7f/dd87d9fbc94787beb85fbea2d91f160d068add": "fd6c34ef87f27f16dda34c3ca31ae453",
".git/objects/81/e2166ae37639f14894660360555209bcd2aac3": "6b7bae10b9052e7644f6113db1649c68",
".git/objects/84/0516208d35dcb4298847ab835e2ef84ada92fa": "36a4a870d8d9c1c623d8e1be329049da",
".git/objects/85/0438c57f682d615f9b33c9564a42aab1e61a41": "a4f72337ac8a6efcf20e77e70cfe4f12",
".git/objects/85/1dc6d863bf876bc03bb70cd4a250eb1013dc22": "ec8e5e025cb0e91a678dbd36b1b9252b",
".git/objects/85/6a39233232244ba2497a38bdd13b2f0db12c82": "eef4643a9711cce94f555ae60fecd388",
".git/objects/87/d99642582d7c72c188633b3e97fea416f8a07e": "3c8af191d729a5000198ab96be2765ef",
".git/objects/87/e7294ee458fcc63431ac313909cf41adc970d9": "0fcb32b2d16321309465d3fdf1251e66",
".git/objects/88/41672db8503dda48424fc1af2390b7351d9c4e": "b4a73ab9a338a94c1508a08ccc998575",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/89/99f90e5cf93545b454b5b977539cfd41df864c": "069448a1c1d5530ccdbfe47849a0cbb6",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/8d/34f956f3c10fa46e4bec672f1d29ae3f044192": "fdcd46e036ab9a928a6cfb4f629fd672",
".git/objects/90/bcfcf0a77ab618a826db0fd8b0942963b653af": "fc109675cdf1233dd6599a4c3c0a7a69",
".git/objects/91/fff79aabe5ad9cd5f675f9468aedd8e26bf01a": "bc636931684a72275ab2bbe53eaa4028",
".git/objects/97/ef0093aae3509020092ec170f87d8c8314d04d": "c39cc189dac29f061ebaab97c52e7d83",
".git/objects/98/57c9b3b0448c92818efc5fda0f206b21914168": "ecbde07c564dabbec0f249821051b8af",
".git/objects/a4/bdc2c9129f7ed1ada57dd027ab4be62e537e29": "c03ca639ee4695fd391046769beb1bc8",
".git/objects/a7/35b78cd1966c9bc1f1d699220992de59d3f03e": "cc03ae03ba5befd18de8af456cb7a602",
".git/objects/a8/95434fb64cf6b5268b1b176d1371e8a1b66b78": "2aceece0ffd3fe98cbd309c77c3db55c",
".git/objects/aa/2d18c32b45ddf08343a5d9ee92314e2726b510": "3dc742f6d90ccd17209fa2be4e9cb891",
".git/objects/aa/4af08fc467e06c7bd377f563f3afaa7c26415f": "4046ae3c23f0530763ea1a40b2339411",
".git/objects/aa/e2bb58c12f4fa72e69f625ffee66abef7e7646": "5b25955ef57f00f7ab9db2ec9c88d4de",
".git/objects/ab/7a67e65873974adc92cdc795854923bc25fbfd": "c98f5e6975071b6d881aedb6a78357b5",
".git/objects/ac/e0476af1c3e5b8e0e842ff89e49b1c46935ced": "860c5c84cdaf61d63d5638b35d8b74a9",
".git/objects/af/ba976ebaba03c445a39a97a99848e081bc4682": "7bca9db1e256359674a1777fbd5c93e1",
".git/objects/b1/5ad935a6a00c2433c7fadad53602c1d0324365": "8f96f41fe1f2721c9e97d75caa004410",
".git/objects/b5/f84d9ef1f45e5814cf237b04722e79ee40c725": "f226d6d81e2b5cb1f8eb19cb6c72f3b1",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/ba/5317db6066f0f7cfe94eec93dc654820ce848c": "9b7629bf1180798cf66df4142eb19a4e",
".git/objects/bb/90d4d8c8f1190f3deeee49240dc429737bbe70": "e80bb1af0aa02de8e89cc9272f3e3d16",
".git/objects/bf/8baaca050a580cdf71d92b3f767ac40ab488e0": "70ec2a98468726b3993f31f1b3874e1d",
".git/objects/c1/ce737f4483ff3c02d0328d199952e4c274ec87": "ea463c38a404beae4d42934bf60801e9",
".git/objects/c5/b10617913fdd5f94215c723c48c633e66276d1": "29b77a85bca8802e02d729bcd606022f",
".git/objects/ca/2ca388ac597d1d4c4f15650fed4d77fcd4a53e": "a4d5cf2d091c705ac92aaa5f21882b7b",
".git/objects/cb/7501cf88832ad3cc5f40e00949c9f0a8e3d394": "372ea9bbac8c3a31a1a26ae97d8c009d",
".git/objects/d0/23371979cf1e985205df19078051c10de0a82d": "700b71074bad7afee32068791dec7442",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d5/bb50b3c3bc534b51ba035a5e8495ba7af5025b": "81d30e6f235d2cd1960b1a0d917b3043",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/da/fd65422747502c19b5c74b4230282644d2169c": "d8a62caf99a372ff6c7692e143787ce3",
".git/objects/dd/5d12458a0deae75b278b71dfa966fd4ad192a3": "9cef17bc04024093061aa8ac46f1eb03",
".git/objects/de/638d69a439a86f0a1e5ae758cc253dc924b865": "2d9c073c3064af71e39d4a012db4874e",
".git/objects/e2/9486da2214a08f695aee1af0ebefc67a51c7e5": "d82291f6e1b07c26454244d4cf5d44b3",
".git/objects/e5/e33d05597957ee9e80d066cd365743c02d768c": "e7268dab1eba9d35ec10f4de8f62be94",
".git/objects/e6/1a2272e3b648dedf9c9164216011f732b9dcb7": "9e3463383fcb465b471f379289528380",
".git/objects/e8/de9d0717bde448c0a4f92473e535720b48df41": "aeda99e2fcf29fe44d19b4134a823726",
".git/objects/e9/70081028956a39104b63b3cf7baac8b8dbc10a": "8560d15ee6b97052830e913a09c30f46",
".git/objects/ea/b60b265a9bc538595ddb4ec934a19955ab12a3": "35cfae817d410549d873ea1e02e3b646",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/f6/c4f9c2219b3e88cc73905be6296780184b078d": "d3a563e51904d25c9bfa2e89ef8d8cc6",
".git/objects/f7/a345cb76ceff075cbc6d2f8d7156fd7bfdca71": "0e2805e2d9d8d5953db877933028d15a",
".git/objects/f8/a4345b4a532ccd354ead10289ed174ef3a4fbf": "55ade11f495177acbecb1592c3c4fa3f",
".git/objects/f9/eab5a4de948804a288d6f98bf99c42a5c39864": "ea464c1e9099e30081476da5ebfec0fe",
".git/objects/fd/2604e38995beeee5b84c9824cbc1b747a1d271": "4998e25315f1a7f7b6358fcbec6cccf8",
".git/objects/ff/da0012d55b11ca6948e5e66f19345606b04b5b": "c2cc9b9441fa33de63d1e5a17d874935",
".git/refs/heads/gh-pages": "cbd25bccebb65d97745220982c593eb5",
".git/refs/heads/master": "4167fc46b88d6bd1b993843edb6a96e2",
".git/refs/remotes/origin/gh-pages": "4167fc46b88d6bd1b993843edb6a96e2",
"assets/AssetManifest.bin": "916ed07fe1a65197fadd22af7851afbd",
"assets/AssetManifest.bin.json": "94691133a874ea4211b7c81b425e0ab1",
"assets/AssetManifest.json": "082654bab2d94dedca4fae57aceefa96",
"assets/FontManifest.json": "ac3f70900a17dc2eb8830a3e27c653c3",
"assets/fonts/MaterialIcons-Regular.otf": "491774d1d7acb4a77099c5515e671ead",
"assets/NOTICES": "6a3ab152d1ecb0a03d4bf1c176169fc8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/syncfusion_flutter_datagrid/assets/font/FilterIcon.ttf": "c17d858d09fb1c596ef0adbf08872086",
"assets/packages/syncfusion_flutter_datagrid/assets/font/UnsortIcon.ttf": "6d8ab59254a120b76bf53f167e809470",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"flutter_bootstrap.js": "c13f9f908ece3e998c8faf746bfc4cd1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "507b4e9b5c02baeae675a5f4565dcc81",
"/": "507b4e9b5c02baeae675a5f4565dcc81",
"main.dart.js": "62701908cafe6cf38fc5930b2e74d6fe",
"manifest.json": "e1a26d4cef67c6717d38ab116f34c0a1",
"version.json": "03d5cb15c8b02fdf83f06c17119b1db2"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
