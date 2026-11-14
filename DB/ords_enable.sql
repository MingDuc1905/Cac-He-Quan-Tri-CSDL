-- ==============================================================================
-- SHIPFOOD - ORACLE 23ai ORDS CONFIGURATION SCRIPT
-- ==============================================================================
-- File: DB/ords_enable.sql
-- Muc dich: Enable Schema SHIPFOOD va 5 JSON Relational Duality Views qua ORDS
-- Luu y: Chay script nay duoi user SYS hoac ADMIN (Autonomous DB), hoac truc tiep
--        bang user SHIPFOOD neu da duoc cap quyen ORDS_ADMINISTRATOR_ROLE.
-- ==============================================================================

-- 0. Bo sung Package pkg_don_hang_state (Tranh loi bien dich trigger mutating table)
CREATE OR REPLACE PACKAGE SHIPFOOD.pkg_don_hang_state AS
    TYPE t_madh_list IS TABLE OF NUMBER(10) INDEX BY PLS_INTEGER;
    v_madh_list t_madh_list;
END pkg_don_hang_state;
/

-- 1. Kich hoat REST cho Schema SHIPFOOD
BEGIN
    ORDS.ENABLE_SCHEMA(
        p_enabled             => TRUE,
        p_schema              => 'SHIPFOOD',
        p_url_mapping_type    => 'BASE_PATH',
        p_url_mapping_pattern => 'shipfood',
        p_auto_rest_auth      => FALSE
    );
    COMMIT;
END;
/

-- 2. Kich hoat REST cho 5 JSON Relational Duality Views
-- Khi enable Duality View, ORDS tu dong sinh day du cac endpoint GET, POST, PUT, DELETE
-- va tu dong anh xa payload JSON xuong cac bang quan he theo quy tac WITH INSERT/UPDATE/DELETE
BEGIN
    -- 2.1 View Don Hang (Nested 3 cap: Don hang -> Chi tiet -> Bien the mon -> Danh gia)
    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'SHIPFOOD',
        p_object         => 'DV_DON_HANG',
        p_object_type    => 'VIEW',
        p_object_alias   => 'dv_don_hang',
        p_auto_rest_auth => FALSE
    );

    -- 2.2 View Khach Hang (Khach hang -> Tai khoan, Dia chi giao hang)
    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'SHIPFOOD',
        p_object         => 'DV_KHACH_HANG',
        p_object_type    => 'VIEW',
        p_object_alias   => 'dv_khach_hang',
        p_auto_rest_auth => FALSE
    );

    -- 2.3 View Quan An (Quan an -> Tai khoan, Thuc don)
    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'SHIPFOOD',
        p_object         => 'DV_QUAN_AN',
        p_object_type    => 'VIEW',
        p_object_alias   => 'dv_quan_an',
        p_auto_rest_auth => FALSE
    );

    -- 2.4 View Mon An (Mon an -> Quan an, Danh muc, Bien the size/gia, Khuyen mai)
    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'SHIPFOOD',
        p_object         => 'DV_MON_AN',
        p_object_type    => 'VIEW',
        p_object_alias   => 'dv_mon_an',
        p_auto_rest_auth => FALSE
    );

    -- 2.5 View Khuyen Mai (Khuyen mai -> Danh sach mon an ap dung)
    ORDS.ENABLE_OBJECT(
        p_enabled        => TRUE,
        p_schema         => 'SHIPFOOD',
        p_object         => 'DV_KHUYEN_MAI',
        p_object_type    => 'VIEW',
        p_object_alias   => 'dv_khuyen_mai',
        p_auto_rest_auth => FALSE
    );

    COMMIT;
END;
/

-- 3. Kiem tra danh sach objects da duoc REST-enabled thanh cong
SELECT id, parsing_schema, type, object_name, uri_prefix, status
FROM user_ords_enabled_objects;
