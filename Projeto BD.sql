-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: estoque
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `compra`
--

DROP TABLE IF EXISTS `compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compra` (
  `id_compra` int NOT NULL AUTO_INCREMENT,
  `data_c` datetime DEFAULT NULL,
  `id_fornecedor` int DEFAULT NULL,
  `numero_nota` varchar(50) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_compra`),
  KEY `id_fornecedor` (`id_fornecedor`),
  CONSTRAINT `compra_ibfk_1` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id_fornecedor`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compra`
--

LOCK TABLES `compra` WRITE;
/*!40000 ALTER TABLE `compra` DISABLE KEYS */;
INSERT INTO `compra` VALUES (1,'2026-05-11 15:49:41',1,'NF001',360.00),(2,'2026-05-11 15:49:41',2,'NF002',700.00);
/*!40000 ALTER TABLE `compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `consumidor`
--

DROP TABLE IF EXISTS `consumidor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `consumidor` (
  `id_consumidor` int NOT NULL AUTO_INCREMENT,
  `id_setor` int DEFAULT NULL,
  `data` datetime DEFAULT NULL,
  PRIMARY KEY (`id_consumidor`),
  KEY `id_setor` (`id_setor`),
  CONSTRAINT `consumidor_ibfk_1` FOREIGN KEY (`id_setor`) REFERENCES `setor` (`id_setor`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `consumidor`
--

LOCK TABLES `consumidor` WRITE;
/*!40000 ALTER TABLE `consumidor` DISABLE KEYS */;
INSERT INTO `consumidor` VALUES (1,1,'2026-05-11 15:51:07'),(2,2,'2026-05-11 15:51:07');
/*!40000 ALTER TABLE `consumidor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalhe_compra`
--

DROP TABLE IF EXISTS `detalhe_compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalhe_compra` (
  `id_detalhe_compra` int NOT NULL AUTO_INCREMENT,
  `id_compra` int DEFAULT NULL,
  `id_produto` int DEFAULT NULL,
  `quantidade` int DEFAULT NULL,
  `preco_unitario` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_detalhe_compra`),
  KEY `id_compra` (`id_compra`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `detalhe_compra_ibfk_1` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`),
  CONSTRAINT `detalhe_compra_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalhe_compra`
--

LOCK TABLES `detalhe_compra` WRITE;
/*!40000 ALTER TABLE `detalhe_compra` DISABLE KEYS */;
INSERT INTO `detalhe_compra` VALUES (1,1,1,2,90.00),(2,1,2,1,180.00),(3,2,3,1,700.00);
/*!40000 ALTER TABLE `detalhe_compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalhe_consumidor`
--

DROP TABLE IF EXISTS `detalhe_consumidor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalhe_consumidor` (
  `id_detalhe_consumidor` int NOT NULL AUTO_INCREMENT,
  `id_consumidor` int DEFAULT NULL,
  `id_produto` int DEFAULT NULL,
  `quantidade` int DEFAULT NULL,
  `preco_unitario` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_detalhe_consumidor`),
  KEY `id_consumidor` (`id_consumidor`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `detalhe_consumidor_ibfk_1` FOREIGN KEY (`id_consumidor`) REFERENCES `consumidor` (`id_consumidor`),
  CONSTRAINT `detalhe_consumidor_ibfk_2` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalhe_consumidor`
--

LOCK TABLES `detalhe_consumidor` WRITE;
/*!40000 ALTER TABLE `detalhe_consumidor` DISABLE KEYS */;
INSERT INTO `detalhe_consumidor` VALUES (1,1,1,1,120.00),(2,2,2,1,250.00);
/*!40000 ALTER TABLE `detalhe_consumidor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fornecedor`
--

DROP TABLE IF EXISTS `fornecedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fornecedor` (
  `id_fornecedor` int NOT NULL AUTO_INCREMENT,
  `nome_fr` varchar(100) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_fornecedor`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fornecedor`
--

LOCK TABLES `fornecedor` WRITE;
/*!40000 ALTER TABLE `fornecedor` DISABLE KEYS */;
INSERT INTO `fornecedor` VALUES (1,'Tech Distribuidora','11999999999','tech@email.com'),(2,'MegaInfo','11888888888','mega@email.com');
/*!40000 ALTER TABLE `fornecedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grupo_produto`
--

DROP TABLE IF EXISTS `grupo_produto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grupo_produto` (
  `id_grupo` int NOT NULL AUTO_INCREMENT,
  `nome_grupo` varchar(100) NOT NULL,
  PRIMARY KEY (`id_grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grupo_produto`
--

LOCK TABLES `grupo_produto` WRITE;
/*!40000 ALTER TABLE `grupo_produto` DISABLE KEYS */;
INSERT INTO `grupo_produto` VALUES (1,'Eletrônicos'),(2,'Periféricos'),(3,'Escritório');
/*!40000 ALTER TABLE `grupo_produto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimento_estoque`
--

DROP TABLE IF EXISTS `movimento_estoque`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimento_estoque` (
  `id_movimento` int NOT NULL AUTO_INCREMENT,
  `id_produto` int DEFAULT NULL,
  `data` datetime DEFAULT NULL,
  `tipo_movimento` varchar(20) DEFAULT NULL,
  `quantidade` int DEFAULT NULL,
  `referencia` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_movimento`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `movimento_estoque_ibfk_1` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimento_estoque`
--

LOCK TABLES `movimento_estoque` WRITE;
/*!40000 ALTER TABLE `movimento_estoque` DISABLE KEYS */;
INSERT INTO `movimento_estoque` VALUES (1,1,'2026-05-11 15:51:59','ENTRADA',2,'Compra NF001'),(2,2,'2026-05-11 15:51:59','ENTRADA',1,'Compra NF001'),(3,3,'2026-05-11 15:51:59','ENTRADA',1,'Compra NF002'),(4,1,'2026-05-11 15:51:59','SAIDA',1,'Setor TI');
/*!40000 ALTER TABLE `movimento_estoque` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produto`
--

DROP TABLE IF EXISTS `produto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produto` (
  `id_produto` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `id_grupo` int DEFAULT NULL,
  `estoque_atual` int DEFAULT '0',
  `estoque_minimo` int DEFAULT '0',
  `preco_medio` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_produto`),
  KEY `id_grupo` (`id_grupo`),
  CONSTRAINT `produto_ibfk_1` FOREIGN KEY (`id_grupo`) REFERENCES `grupo_produto` (`id_grupo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produto`
--

LOCK TABLES `produto` WRITE;
/*!40000 ALTER TABLE `produto` DISABLE KEYS */;
INSERT INTO `produto` VALUES (1,'Mouse Gamer','Mouse RGB',2,50,10,120.00),(2,'Teclado Mecânico','Teclado RGB',2,30,5,250.00),(3,'Monitor 24','Monitor Full HD',1,15,3,900.00);
/*!40000 ALTER TABLE `produto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produto_fornecedor`
--

DROP TABLE IF EXISTS `produto_fornecedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produto_fornecedor` (
  `id_produto` int NOT NULL,
  `id_fornecedor` int NOT NULL,
  `preco_compra` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id_produto`,`id_fornecedor`),
  KEY `id_fornecedor` (`id_fornecedor`),
  CONSTRAINT `produto_fornecedor_ibfk_1` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`id_produto`),
  CONSTRAINT `produto_fornecedor_ibfk_2` FOREIGN KEY (`id_fornecedor`) REFERENCES `fornecedor` (`id_fornecedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produto_fornecedor`
--

LOCK TABLES `produto_fornecedor` WRITE;
/*!40000 ALTER TABLE `produto_fornecedor` DISABLE KEYS */;
INSERT INTO `produto_fornecedor` VALUES (1,1,90.00),(1,2,95.00),(2,1,180.00),(3,2,700.00);
/*!40000 ALTER TABLE `produto_fornecedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `setor`
--

DROP TABLE IF EXISTS `setor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setor` (
  `id_setor` int NOT NULL AUTO_INCREMENT,
  `nome_setor` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_setor`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setor`
--

LOCK TABLES `setor` WRITE;
/*!40000 ALTER TABLE `setor` DISABLE KEYS */;
INSERT INTO `setor` VALUES (1,'TI'),(2,'Administrativo'),(3,'Financeiro');
/*!40000 ALTER TABLE `setor` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-11 16:03:42
