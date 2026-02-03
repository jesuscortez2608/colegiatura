CREATE TABLE sapfamiliarhojas
(
  numemp bigint DEFAULT 0,
  clave integer DEFAULT 0,
  numerofamiliares integer DEFAULT 0,
  parentesco integer DEFAULT 0,
  apellidopaterno character(20) DEFAULT ''::bpchar,
  apellidomaterno character(20) DEFAULT ''::bpchar,
  nombre character(20) DEFAULT ''::bpchar,
  fechanacimiento date DEFAULT '1900-01-01'::date,
  escolaridad character(30) DEFAULT ''::bpchar,
  empresa character(40) DEFAULT ''::bpchar,
  ocupacion character(30) DEFAULT ''::bpchar,
  telefonoempresa character(12) DEFAULT ''::bpchar,
  telefonocasa character(12) DEFAULT ''::bpchar,
  numeroelp bigint DEFAULT 0,
  fechacaptura date DEFAULT now(),
  keyx integer NOT NULL DEFAULT 0,
  personasdependientes integer NOT NULL DEFAULT 0,
  beneficiarioactivo integer NOT NULL DEFAULT 0
);