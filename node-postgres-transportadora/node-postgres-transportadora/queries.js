var promise = require('bluebird');

var options = {
    // Initialization Options
    promiseLib: promise
};

var pgp = require('pg-promise')(options);
// var connectionString = 'postgres://postgres:postgres@localhost:5432/LabBD';
const cn = {
    host: 'localhost',
    port: 5432,
    database: 'LabBD',
    user: 'app_role_select',
    password: 'postgres'
};
var db = pgp(cn);

// add query functions
function getViagensByNomeDest(req, res, next) {
    var nomeDest = req.params.nome;
    var limit = parseInt(req.params.limit);
    var offset = parseInt(req.params.offset);
    db.any('SELECT * FROM consultar_viagens($1, $2, $3)', [nomeDest + '%', limit, offset])
        .then(function (data) {
            res.status(200)
                .json({
                    status: 'success',
                    data: data,
                    message: 'Viagens recuperadas'
                });
        })
        .catch(function (err) {
            return next(err);
        });
}

function getVeiculosByMercadoria(req, res, next) {
    var pesoMinimo = parseInt(req.params.pesoMinimo);
    var pesoMaximo = parseInt(req.params.pesoMaximo);
    var qtdVolumesMinimo = parseInt(req.params.qtdVolumesMinimo);
    var qtdVolumesMaximo = parseInt(req.params.qtdVolumesMaximo);
    var limit = parseInt(req.params.limit);
    var offset = parseInt(req.params.offset);
    db.any('SELECT * FROM consultar_veiculos($1, $2, $3, $4, $5, $6)', [pesoMinimo, pesoMaximo, qtdVolumesMinimo, qtdVolumesMaximo, limit, offset])
        .then(function (data) {
            res.status(200)
                .json({
                    status: 'success',
                    data: data,
                    message: 'Veiculos recuperados'
                });
        })
        .catch(function (err) {
            console.error(err);
            return next(err);
        });
}

module.exports = {
    getViagensByNomeDest: getViagensByNomeDest,
    getVeiculosByMercadoria: getVeiculosByMercadoria
};
