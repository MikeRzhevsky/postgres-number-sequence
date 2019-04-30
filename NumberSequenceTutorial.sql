--Tutorial number sequence for kontragent
--https://viccherubini.com/2017/02/25/generating-custom-sequences-in-postgres/
--we’ll need a table to track sequence names, the kontragent they are associated with, a prefix, and their next value.

--Step 1 : 
CREATE TABLE number_sequence (

  sequence_id serial NOT NULL,      -- id of records

  tablename varchar(100) NOT NULL , --reference to table

  sequence varchar(100) NOT NULL,   -- name of sequence

  prefix varchar(100) NOT NULL DEFAULT ''::text, --prefix

  next_value integer NOT NULL DEFAULT 1, -- next number

  zero_pad integer,                      -- number of 0 filled

  CONSTRAINT kontragent_sequence_pkey PRIMARY KEY (sequence_id) --PK

) WITH (OIDS=FALSE);

-- we’ll write a short stored procedure named generate_sequence() to generate the next value in a sequence.

--Step2 :
CREATE OR REPLACE FUNCTION generate_sequence(_tablename text, --real record from table
											 _sequence text) RETURNS TEXT AS $$

DECLARE

  _prefix text;

  _next_value text;

  _zero_pad integer;

  _value text;

BEGIN

  SELECT asq.prefix, asq.next_value::text, asq.zero_pad

  INTO _prefix, _next_value, _zero_pad

  FROM tbl_number_sequence asq

  WHERE asq.tablename = _tablename

    AND asq.sequence = _sequence;



  IF _zero_pad IS NOT NULL THEN

_next_value:=lpad(_next_value, _zero_pad, '0'  );

  END IF;

  _value := _prefix || _next_value;


  UPDATE number_sequence SET

    next_value = next_value + 1

  WHERE tablename = _tablename

    AND sequence = _sequence;



  RETURN _value;

END;

$$ LANGUAGE plpgsql;

--create first record in tbl_number_sequence

--Step3:
1	account	account	КЛН-	104	5

--validate number sequence: 345 - record from tbl_kontragent, invoice from  sequence 
--Step4 
SELECT generate_sequence('account', 'account');


