/*
Borro las tablas si existen
*/
DROP TABLE IF EXISTS public.pesca;
DROP TABLE IF EXISTS public.departamento;
DROP TABLE IF EXISTS public.provincia;

/* Creo la tabla principal */

CREATE TABLE public.provincia (
    id BIGINT,
    nombre VARCHAR,
    nombre_completo VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    categoria VARCHAR
);
CREATE TABLE public.departamento (
    id BIGINT,
    nombre VARCHAR,
    nombre_completo VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    categoria VARCHAR,
    provincia_id BIGINT
);

CREATE TABLE public.pesca (
    id SERIAL,
    fecha VARCHAR(10),
    flota VARCHAR(100),
    puerto VARCHAR(100),
    latitud FLOAT,
    longitud FLOAT,
    categoria VARCHAR(50),
    especie VARCHAR(100),
    especie_agrupada VARCHAR(100),
    captura BIGINT,
    departamento_id BIGINT
);

/*
Agrego las restricciones de clave primaria y foránea a las tablas
*/

ALTER TABLE public.pesca
ADD CONSTRAINT pesca_pk PRIMARY KEY (id);

ALTER TABLE public.departamento
ADD CONSTRAINT departamento_pk PRIMARY KEY (id);

ALTER TABLE public.provincia
ADD CONSTRAINT provincia_pk PRIMARY KEY (id);

ALTER TABLE public.departamento
ADD CONSTRAINT fk_departamento_provincia FOREIGN KEY (provincia_id) REFERENCES provincia (id);

ALTER TABLE public.pesca 
ADD CONSTRAINT fk_pesca_departamento FOREIGN KEY (departamento_id) REFERENCES departamento (id);

/*
Tablas temporales para carga de datos
*/
CREATE TEMPORARY TABLE temp_departamentos (
    categoria VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    fuente VARCHAR,
    id VARCHAR,
    nombre VARCHAR,
    nombre_completo VARCHAR,
    provincia_id VARCHAR,
    provincia_interseccion FLOAT,
    provincia_nombre VARCHAR
);

CREATE TEMPORARY TABLE provincias_temp (
    categoria VARCHAR,
    centroide_lat FLOAT,
    centroide_lon FLOAT,
    fuente VARCHAR,
    id VARCHAR,
    iso_id VARCHAR,
    iso_nombre VARCHAR,
    nombre VARCHAR,
    nombre_completo VARCHAR
);

CREATE TEMPORARY TABLE pesca_temp (
    fecha VARCHAR,
    flota VARCHAR,
    puerto VARCHAR,
    provincia VARCHAR,
    provincia_id VARCHAR,
    departamento VARCHAR,
    departamento_id VARCHAR,
    latitud FLOAT,
    longitud FLOAT,
    categoria VARCHAR,
    especie VARCHAR,
    especie_agrupada VARCHAR,
    captura BIGINT
);

/*
Carga de datos en tablas temporales
*/
COPY provincias_temp
FROM '/datos/provincias.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    public.provincia (
        id,
        nombre,
        nombre_completo,
        centroide_lat,
        centroide_lon,
        categoria
    )
SELECT
    id::INTEGER,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria
FROM provincias_temp;

COPY temp_departamentos
FROM '/datos/departamentos.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    public.departamento (
        id,
        nombre,
        nombre_completo,
        centroide_lat,
        centroide_lon,
        categoria,
        provincia_id
    )
SELECT
    id::INTEGER,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria,
    provincia_id::INTEGER
FROM temp_departamentos;

COPY pesca_temp
FROM '/datos/captura-puerto-flota-2019-utf8.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    public.pesca (
        fecha,
        flota,
        puerto,
        latitud,
        longitud,
        categoria,
        especie,
        especie_agrupada,
        captura,
        departamento_id
    )
SELECT
    fecha,
    flota,
    puerto,
    latitud,
    longitud,
    categoria,
    especie,
    especie_agrupada,
    captura,
    departamento_id::INTEGER

FROM pesca_temp
WHERE departamento_id::BIGINT IN (SELECT id FROM departamento);
/*  
Carga de datos en la tabla definitiva
*/
INSERT INTO public.provincia (
    id,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria
)
SELECT DISTINCT
    id::BIGINT,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria
FROM provincias_temp
WHERE id IS NOT NULL
  AND id::BIGINT NOT IN (SELECT id FROM public.provincia);

-- Departamentos únicos
INSERT INTO public.departamento (
    id,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria,
    provincia_id
)
SELECT DISTINCT
    id::BIGINT,
    nombre,
    nombre_completo,
    centroide_lat,
    centroide_lon,
    categoria,
    provincia_id::BIGINT
FROM temp_departamentos
WHERE id IS NOT NULL
  AND id::BIGINT NOT IN (SELECT id FROM public.departamento);

INSERT INTO public.pesca (
    fecha,
    flota,
    puerto,
    latitud,
    longitud,
    categoria,
    especie,
    especie_agrupada,
    captura,
    departamento_id
)
SELECT
    fecha,
    flota,
    puerto,
    latitud,
    longitud,
    categoria,
    especie,
    especie_agrupada,
    captura,
    departamento_id::BIGINT
FROM pesca_temp
WHERE departamento_id::BIGINT IN (SELECT id FROM departamento);


