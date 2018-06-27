DROP INDEX IF EXISTS idx_motorista_viagem_placa;
DROP INDEX IF EXISTS idx_veiculo_placa;
DROP INDEX IF EXISTS idx_entrega_codigo_viagem;
DROP INDEX IF EXISTS idx_mercadoria_nf;
DROP INDEX IF EXISTS idx_mercadoria_peso_qtd_volumes;

---------------------------------------------------------------------------

CREATE INDEX idx_motorista_viagem_placa ON motorista_viagem (placa);
CREATE INDEX idx_veiculo_placa ON veiculo (placa);
CREATE INDEX idx_entrega_codigo_viagem ON entrega (codigo_viagem);
CREATE UNIQUE INDEX idx_mercadoria_nf ON mercadoria (nf);
CREATE INDEX idx_mercadoria_peso_qtd_volumes ON mercadoria (peso, qtd_volumes);

---------------------------------------------------------------------------

-- Consulta Antiga

SELECT  mercadoria.peso AS peso, 
        mercadoria.qtd_volumes AS qtd_volumes, 
        mercadoria_entrega.placa AS placa, 
        mercadoria_entrega.modelo AS modelo, 
        mercadoria_entrega.capacidade AS capacidade
FROM mercadoria 
  INNER JOIN (
    SELECT  entrega.nf AS nf, 
            veiculo_viagem.placa AS placa, 
            veiculo_viagem.modelo AS modelo, 
            veiculo_viagem.capacidade AS capacidade
    FROM entrega
      INNER JOIN (
        SELECT  veiculo.placa AS placa,
                veiculo.modelo AS modelo,
                veiculo.capacidade AS capacidade,
                motorista_viagem.codigo_viagem AS codigo_viagem
        FROM veiculo
          INNER JOIN motorista_viagem
          ON veiculo.placa = motorista_viagem.placa
                  ) AS veiculo_viagem
      ON entrega.codigo_viagem = veiculo_viagem.codigo_viagem
              ) AS mercadoria_entrega
  ON mercadoria.nf = mercadoria_entrega.nf
WHERE peso > 0 AND peso < 35 AND qtd_volumes > 0 AND qtd_volumes < 5
ORDER BY peso;

---------------------------------------------------------------------------------

-- Consulta Otimizada

SELECT  mercadoria.peso AS peso, 
        mercadoria.qtd_volumes AS qtd_volumes, 
        mercadoria_entrega.placa AS placa, 
        mercadoria_entrega.modelo AS modelo, 
        mercadoria_entrega.capacidade AS capacidade
FROM (
        SELECT peso, qtd_volumes, nf
        FROM mercadoria
        WHERE peso > 0 AND peso < 35 AND qtd_volumes > 0 AND qtd_volumes < 5
        ORDER BY peso
    ) AS mercadoria
  INNER JOIN (
    SELECT  entrega.nf AS nf, 
            veiculo_viagem.placa AS placa, 
            veiculo_viagem.modelo AS modelo, 
            veiculo_viagem.capacidade AS capacidade
    FROM entrega
      INNER JOIN (
        SELECT  veiculo.placa AS placa,
                veiculo.modelo AS modelo,
                veiculo.capacidade AS capacidade,
                motorista_viagem.codigo_viagem AS codigo_viagem
        FROM veiculo
          INNER JOIN motorista_viagem
          ON veiculo.placa = motorista_viagem.placa
                  ) AS veiculo_viagem
      ON entrega.codigo_viagem = veiculo_viagem.codigo_viagem
              ) AS mercadoria_entrega
  ON mercadoria.nf = mercadoria_entrega.nf;