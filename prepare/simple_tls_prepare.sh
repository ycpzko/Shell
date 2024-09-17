improt_package "utils" "gen_certificates.sh"

# simple-tls version
SIMPLE_TLS_VERSION=(
v0.3.4
v0.4.7
v0.7.0
latest
)

# simple-tls Transport mode
MODE_V034=(
tls
wss
)

CERTIFICATE_TYPE=(
"临时证书"
"固定证书"
)


is_enable_random_header_for_v034(){
    while true
    do
        _read "是否启用random header(512b~16Kb)以防止流量分析(rh) (默认: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableRh=enable
                ;;
            n|N)
                isEnableRh=disable
                ;;
            *)
                _echo -e "输入有误，请重新输入."
                continue
                ;;
        esac
        _echo -r "  rh = ${isEnableRh}"
        break
    done
}

is_enable_padding_data_for_v047(){
    while true
    do
        _read "是否启用padding-data模式，以防止流量分析(pd) (默认: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnablePd=enable
                ;;
            n|N)
                isEnablePd=disable
                ;;
            *)
                _echo -e "输入有误，请重新输入."
                continue
                ;;
        esac
        _echo -r "  pd = ${isEnablePd}"
        break
    done
}

is_enable_ws_for_v070(){
    while true
    do
        echo
        _read "是否启用WebSocket (ws) (默认: n) [y/n]: "
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableWs=enable
                ;;
            n|N)
                isEnableWs=disable
                ;;
            *)
                _echo -e "输入有误，请重新输入."
                continue
                ;;
        esac
        _echo -r "  ws = ${isEnableWs}"
        break
    done
}

is_enable_auth_for_v070(){
    while true
    do
        echo
        _read "是否启用身份验证密码，以过滤扫描流量(auth) (默认: n) [y/n]: "
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableAuth=enable
                ;;
            n|N)
                isEnableAuth=disable
                ;;
            *)
                _echo -e "输入有误，请重新输入."
                continue
                ;;
        esac
        _echo -r "  auth = ${isEnableAuth}"
        break
    done
}

get_input_auth_passwd_for_v070(){
    gen_random_str
    _read "请输入身份验证密码 (默认: ${ran_str12}):"
    auth="${inputInfo}"
    [ -z "${auth}" ] && auth="${ran_str12}"
    _echo -r "${Red}  auth = ${auth}${suffix}"
}

is_enable_grpc_for_latest(){
    while true
    do
        echo
        _read "是否启用gRPC (grpc) (默认: n) [y/n]: "
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableGrpc=enable
                ;;
            n|N)
                isEnableGrpc=disable
                ;;
            *)
                _echo -e "输入有误，请重新输入."
                continue
                ;;
        esac
        _echo -r "  grpc = ${isEnableGrpc}"
        break
    done
}

tls_mode_logic_for_v034(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_enable_random_header_for_v034
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

wss_mode_logic_for_v034(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    get_input_ws_path
    is_enable_random_header_for_v034
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

version_034_logic(){
    generate_menu_logic "${MODE_V034[*]}" "传输模式" "1"
    modeOptsNumV034="${inputInfo}"
    if [ "${modeOptsNumV034}" = "1" ]; then
        tls_mode_logic_for_v034
    elif [ "${modeOptsNumV034}" = "2" ]; then
        wss_mode_logic_for_v034
    fi
}

version_047_logic(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_enable_padding_data_for_v047
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

version_v070_logic(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
        generate_menu_logic "${CERTIFICATE_TYPE[*]}" "证书类型(无合法证书时)" "1"
        certificateTypeOptNum="${inputInfo}"
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_disable_mux_logic
    is_enable_auth_for_v070
    if [ "${isEnableAuth}" = "enable" ]; then
        get_input_auth_passwd_for_v070
    fi
    is_enable_ws_for_v070
    if [ "${isEnableWs}" = "enable" ]; then
        get_input_ws_path
    fi
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

version_latest_logic(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
        generate_menu_logic "${CERTIFICATE_TYPE[*]}" "证书类型(无合法证书时)" "1"
        certificateTypeOptNum="${inputInfo}"
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_enable_grpc_for_latest
    if [ "${isEnableGrpc}" = "enable" ]; then
        get_input_grpc_path
    fi
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

install_prepare_libev_simple_tls(){
    generate_menu_logic "${SIMPLE_TLS_VERSION[*]}" "simple-tls版本" "4"
    SimpleTlsVer="${inputInfo}"
    improt_package "utils" "common_prepare.sh"
    if [ "${SimpleTlsVer}" = "1" ]; then
        version_034_logic
    elif [ "${SimpleTlsVer}" = "2" ]; then
        version_047_logic
    elif [ "${SimpleTlsVer}" = "3" ]; then
        version_v070_logic
    elif [ "${SimpleTlsVer}" = "4" ]; then
        version_latest_logic
    fi
}