USE BD044152
-- Exercicio 18
GO
WITH MonthlySales AS (
  SELECT
    YEAR(DataPedido) AS Ano,
    MONTH(DataPedido) AS Mes,
    SUM(ValorLiquido) AS ValorTotal
  FROM
    dbo.Venda
  GROUP BY
    YEAR(DataPedido),
    MONTH(DataPedido)
),
PivotedSales AS (
  SELECT
    Ano,
    [1] AS Jan, [2] AS Fev, [3] AS Mar, [4] AS Abr, [5] AS Mai, [6] AS Jun,
    [7] AS Jul, [8] AS Ago, [9] AS [Set], [10] AS Out, [11] AS Nov, [12] AS Dez
  FROM
    MonthlySales
  PIVOT (
    SUM(ValorTotal)
    FOR Mes IN
    ([1], [2], [3], [4], [5], [6],
     [7], [8], [9], [10], [11], [12])
  ) AS PivotTable
)
SELECT
  Ano,
  Jan, Fev, Mar, Abr, Mai, Jun,
  Jul, Ago, [Set], Out, Nov, Dez,
  CASE WHEN Jan > 0 THEN (Fev - Jan) / NULLIF(Jan, 0) ELSE NULL END AS CrescimentoJanFev,
  CASE WHEN Fev > 0 THEN (Mar - Fev) / NULLIF(Fev, 0) ELSE NULL END AS CrescimentoFevMar
FROM
  PivotedSales


  --Exercicio 19
 GO
 WITH RankedPurchases AS (
    SELECT
        c.Nome,
        v.DataPedido,
        v.ValorLiquido,
        ROW_NUMBER() OVER (PARTITION BY v.ClienteID ORDER BY v.DataPedido DESC) AS PurchaseRank
    FROM
        dbo.Venda v
    INNER JOIN
        dbo.Cliente c ON v.ClienteID = c.ClienteID
)
SELECT
    Nome,
    DataPedido,
    ValorLiquido
FROM
    RankedPurchases
WHERE
    PurchaseRank <= 2;
	GO
	
-----------------Exercicio 20---------------

CREATE TABLE #twenty (
    Produto NVARCHAR(100),
    DataVenda NVARCHAR(100),
    QtdeVendida int
);
INSERT INTO #twenty (Produto,DataVenda,QtdeVendida)  
(
    SELECT 
        -- TOP(10)
        -- *
        p.Descricao AS Produto,
        FORMAT(v.DataPedido, 'dd/MM/yyyy') AS DataVenda,
        SUM(vp.QtdeVendida) AS QtdeVendida
    FROM Venda as v
        INNER JOIN VendaProduto as vp
        ON v.VendaID  = vp.VendaID
        INNER JOIN Produto as p
        ON p.ProdutoID = vp.ProdutoID
    GROUP BY p.Descricao, FORMAT(v.DataPedido, 'dd/MM/yyyy')
)
GO
WITH VendasNumeradas AS (
    SELECT
        *
        , ROW_NUMBER() OVER (PARTITION BY Produto ORDER BY DataVenda DESC) AS numero_de_linha
    FROM
        #twenty
)
SELECT
    *
FROM
    VendasNumeradas
WHERE
    numero_de_linha <= 2;

DROP TABLE #twenty


-----------------Exercicio 21---------------
DECLARE @ProdutoID INT, @QtdeVendida INT, @Descricao VARCHAR(200);
DECLARE @VendasPorProduto TABLE (ProdutoID INT, Descricao VARCHAR(200), QuantidadeTotal INT);

DECLARE vendas_cursor CURSOR FOR
SELECT vp.ProdutoID, SUM(vp.QtdeVendida) AS QuantidadeTotal, p.Descricao
FROM dbo.VendaProduto vp
JOIN dbo.Produto p ON vp.ProdutoID = p.ProdutoID
GROUP BY vp.ProdutoID, p.Descricao;

OPEN vendas_cursor;
FETCH NEXT FROM vendas_cursor INTO @ProdutoID, @QtdeVendida, @Descricao;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO @VendasPorProduto (ProdutoID, Descricao, QuantidadeTotal) VALUES (@ProdutoID, @Descricao, @QtdeVendida);
    FETCH NEXT FROM vendas_cursor INTO @ProdutoID, @QtdeVendida, @Descricao;
END;

CLOSE vendas_cursor;
DEALLOCATE vendas_cursor;

SELECT TOP 5 ProdutoID, Descricao, QuantidadeTotal
FROM @VendasPorProduto
ORDER BY QuantidadeTotal DESC;






