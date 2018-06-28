var express = require('express');
var router = express.Router();

var db = require('../queries');


router.get('/api/viagens/:nome/:limit/:offset', db.getViagensByNomeDest);
router.get('/api/veiculos/:pesoMinimo/:pesoMaximo/:qtdVolumesMinimo/:qtdVolumesMaximo/:limit/:offset', db.getVeiculosByMercadoria);


module.exports = router;