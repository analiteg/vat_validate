CLASS lcl_vat_validate DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ls_vat_response,
        query           TYPE string,
        vat_number      TYPE string,
        valid           TYPE string,
        country_code    TYPE string,
        company_name    TYPE string,
        company_address TYPE string,
      END OF ls_vat_response.

    CLASS-METHODS create
      RETURNING VALUE(ro_vat) TYPE REF TO lcl_vat_validate.

    METHODS create_client
      IMPORTING url           TYPE string
      RETURNING VALUE(result) TYPE REF TO if_web_http_client
      RAISING   cx_static_check.

    METHODS run
      IMPORTING lv_vat_number TYPE string
      RETURNING VALUE(lt_vat) TYPE ls_vat_response
      RAISING   cx_static_check.

  PRIVATE SECTION.
    CONSTANTS base_url TYPE string VALUE 'http://apilayer.net/api/validate'.
    CONSTANTS api_key  TYPE string VALUE '668513636eefb52a8ff2b058b9da8d9a'.

ENDCLASS.


CLASS lcl_vat_validate IMPLEMENTATION.
  METHOD create.
    ro_vat = NEW lcl_vat_validate( ).
  ENDMETHOD.

  METHOD create_client.
    DATA(dest) = cl_http_destination_provider=>create_by_url( url ).
    result = cl_web_http_client_manager=>create_by_http_destination( dest ).
  ENDMETHOD.

  METHOD run.
    " Get Data from URL
    DATA(url) = |{ base_url }| & |?access_key=| & |{ api_key }| & |&vat_number=| & |{ lv_vat_number }|.
    DATA(client) = create_client( url ).
    DATA(response) = client->execute( if_web_http_client=>get )->get_text( ).
    client->close( ).

    " Convert data from JSON
    DATA my_result TYPE string_table.
    xco_cp_json=>data->from_string( response )->apply(
                                                 VALUE #( ( xco_cp_json=>transformation->camel_case_to_underscore ) )
     )->write_to( REF #( my_result ) ).

    " Create response
    lt_vat-query           = my_result[ 4 ].
    lt_vat-vat_number      = my_result[ 6 ].
    lt_vat-valid           = my_result[ 1 ].
    lt_vat-country_code    = my_result[ 5 ].
    lt_vat-company_name    = my_result[ 7 ].
    lt_vat-company_address = replace( val = my_result[ 8 ] pcre = `\n` with = `` ).
  ENDMETHOD.
ENDCLASS.
