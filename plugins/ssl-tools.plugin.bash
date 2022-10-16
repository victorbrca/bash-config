#
## about:Aliases for SSL
#

if ! command -v openssl > /dev/null ; then
  echo "[bash-config] OpenSSL is not installed"
  return 1
fi

_ssl-tool_view ()
{
  local usage file file_type
  usage="ssl-tool view [file]"
  if [[ $# -ne 1 ]] ; then
    echo "$usage"
    return 0
  fi
  file="$1"
  test -f "$file" || { echo "File \"${file}\" doesn't exist" ; return 1 ; }
  file_type="$(file $file | awk '{print $2}')"
  case "$file" in
    *key*|*.key)
        if [[ $file_type =~ (ASCII|PEM) ]] ; then
          openssl rsa -noout -text -in "$1" | \less
        fi
        ;;
    *.crt|*.cer|*.cert)
        if [[ $file_type =~ (ASCII|PEM) ]] ; then
          openssl x509 -in "$1" -text -noout | \less
        elif [[ $file_type =~ (DER|data) ]] ; then
          openssl x509 -inform der -in "$1" -text -noout | \less
        fi
        ;;
    *.pem)
        openssl x509 -in "$1" -text -noout | \less
        ;;
    *.der)
        openssl x509 -inform der -in "$1" -text -noout | \less
        ;;
    *.csr)
        if [[ $file_type =~ (ASCII|PEM|RFC1421) ]] ; then
          openssl req -noout -text -in "$1" | \less
        elif [[ $file_type =~ (DER|data) ]] ; then
          openssl req -noout -text -inform der -in "$1" | \less
        fi
        ;;
    *.p12)
        openssl pkcs12 -in "$1" | \less
        ;;
    *.p7b)
        if [[ $file_type =~ (ASCII|PEM|RFC1421) ]] ; then
          openssl pkcs7 -print_certs -in "$1" | openssl x509 -text -noout | \less
        elif [[ $file_type =~ (DER|data) ]] ; then
          openssl pkcs7 -inform DER -print_certs -in "$1" | openssl x509 -text -noout | \less
        fi
        ;;
  esac
}

_ssl-tool_connect_download ()
{
  local OPTIND OPT OPTERR usage port cafile opts server action
  usage="ssl-tool [connect|download] [server] {-p port|-c certificate.cer}"
  action="$1"
  shift
  server="$1"
  if [[ $# -eq 0 ]] ; then
    echo "$usage"
    return 0
  elif [[ $# -gt 1 ]] ; then
    OPTERR=0
    shift
    while getopts "p:c:" OPT ; do
      case $OPT in
        p) port="$OPTARG" ;;
        c) cafile="$OPTARG" ;;
      esac
    done
  fi
  
  port=${port:-443}

  if [ "$cafile" ] ; then
    opts="-CAfile $cafile"
  fi

  case $action in
    connect)
        echo | timeout 2 openssl s_client -connect ${server}:${port} ${opts} 2> \
        /dev/null | grep -E --color 'Verify return code.*|$' \
        || { echo "failed" ; return 1 ; }
        ;;
    download)
        echo | timeout 2 openssl s_client -connect ${server}:${port} ${opts} 2>&1 \
        | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${server}.cer
        if [[ ${PIPESTATUS[1]} -eq 0 ]] ; then
          echo "Certificate file saved to ${server}.cer"
        else
          echo "failed"
          command rm "${server}.cer"
          return 1
        fi
        ;;
    esac
}

_ssl-tool_convert ()
{
  local usage file out_format file_type answer
  usage="ssl-tool convert [file] [format]"
  [[ $# -ne 2 ]] && { echo "$usage" ; return 0 ; }
  file="$1"
  out_format="$2"
  test -f "$file" || { echo "File \"${file}\" doesn't exist" ; return 1 ; }

  # .pem to .der
  if [[ $file =~ .pem ]] && [[ "$out_format"  == "der" ]] ; then
    openssl x509 -in "$file" -outform der -out "${file%.*}.der"

  # .pem to .cer
  elif [[ $file =~ .pem ]] && [[ $out_format  =~ c(er|rt) ]] ; then
    echo -e "Would you like the certificate to be encoded in:\n1- PEM (ASCII)\n2- DER (binary)"
    read -p "[1|2]: " answer
    case "$answer" in
      1|pem|PEM|ascii|ASCII) openssl x509 -in "$file" -out "${file%.*}.cer" ;;
      2|der|DER|binary) openssl x509 -in "$file" -outform der -out "${file%.*}.${out_format}" ;;
      *) echo "Wrong option. Try again" ; return 1 ;;
    esac
 
  # .der to .pem
  elif [[ $file =~ .der ]] && [[ "$out_format"  == "pem" ]] ; then
    openssl x509 -in "$file" -inform der -out "${file%.*}.pem"

  # .der to .cer
  elif [[ $file =~ .der && ( "$out_format"  == "cer" || "$out_format"  == "crt" ) ]] ; then
    echo -e "Would you like the certificate to be encoded in:\n1- PEM (ASCII)\n2- DER (binary)"
    read -p "[1|2]: " answer
    case "$answer" in
      1|pem|PEM|ascii|ASCII) openssl x509 -in "$file" -inform der -outform pem -out "${file%.*}.${out_format}" ;;
      2|der|DER|binary) openssl x509 -in "$file" -inform der -outform der -out "${file%.*}.${out_format}" ;;
      *) echo "Wrong option. Try again" ; return 1 ;;
    esac

  # .cer to .pem
  ########## crt to pem not working
  elif [[ $file =~ .c(rt|er) ]] && [[ "$out_format"  == "pem" ]] ; then
    file_type="$(file $file | awk '{print $2}')"
    if [[ "$file_type" = "DER" ]] ; then
      openssl x509 -inform der -in "$file" -outform pem -out "${file%.*}.pem"
    elif [[ $file_type =~ (PEM|ASCII) ]] ; then
      openssl x509 -in "$file" -outform pem -out "${file%.*}.pem"
    fi

  # .cer to .der
  elif [[ $file =~ .c(rt|er) ]] && [[ "$out_format"  == "der" ]] ; then
    file_type="$(file $file | awk '{print $2}')"
    if [[ "$file_type" = "DER" ]] ; then
      openssl x509 -inform der -in "$file" -out "${file%.*}.der"
    elif [[ $file_type =~ (PEM|ASCII) ]] ; then
      openssl x509 -in "$file" -outform der -out "${file%.*}.der"
    fi

  else
    echo "Could not do anything"
  fi
}

_ssl-tool_extract ()
{
  local usage file file_type p7b_certs p12_certs
  usage="ssl-tool extract [file]"
  if [[ $# -ne 1 ]] ; then
    echo "$usage"
    return 0
  fi
  file="$1"
  test -f "$file" || { echo "File \"${file}\" doesn't exist" ; return 1 ; }
  file_type="$(file $file | awk '{print $2}')"
  case "$file" in
    *.p7b)
        if [[ $file_type =~ (ASCII|PEM) ]] ; then
          p7b_certs="$(openssl pkcs7 -in "$file" -print_certs | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"
        elif [[ $file_type =~ (DER|data) ]] ; then
          p7b_certs="$(openssl pkcs7 -inform DER -in "$file" -print_certs | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"
        else
          echo "Could not determine format of p7b file for extraction"
          return 1
        fi
        # Server certificate
        echo "$p7b_certs" | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' -e '/-END CERTIFICATE-/q' > "${file%.*}.server.cer"
        # Root certificate
        echo "-----BEGIN CERTIFICATE-----" > "${file%.*}.root.cer"
        echo "$p7b_certs" | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sed -e '1,/-BEGIN CERTIFICATE-/ d' >> "${file%.*}.root.cer"
        ;;
    *.p12)
        p12_certs="$(openssl pkcs12 -info -nodes -in "$file" 2> /dev/null)"
        # Private key
        echo "$p12_certs" | sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > "${file%.*}.private.key.cer"
        # Server certificate
        echo "$p12_certs" | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' -e '/-END CERTIFICATE-/q' > "${file%.*}.server.cer"
        # Root certificate
        echo "-----BEGIN CERTIFICATE-----" > "${file%.*}.root.cer"
        echo "$p12_certs" | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sed -e '1,/-BEGIN CERTIFICATE-/ d' >> "${file%.*}.root.cer"
        ;;
  esac
}

_ssl-tool_check ()
{
  local usage file
  usage="ssl-tool check [key file]\nssl-tool check [cer or pem file] date"
  if [[ $# -eq 1 ]] ; then
    file="$1"
    case "$file" in
      *key*|*.key)
          openssl rsa -in "$file" -check 2> /dev/null | head -1 
          ;;
      *)
          echo "Wrong option"
          echo -e "$usage"
          return 1
    esac
  elif [[ $# -eq 2 ]] && [[ $1 =~ (cer|pem) ]] && [[ "$2" == "date" ]] ; then
    file="$1"
    test -f "$file" || { echo "File \"${file}\" doesn't exist" ; return 1 ; }
    file_type="$(file $file | awk '{print $2}')"
    if [[ $file_type =~ (ASCII|PEM) ]] ; then
      openssl x509 -noout -in "$file" -dates
    elif [[ $file_type =~ (DER|data) ]] ; then
      openssl x509 -noout -inform der -in "$file" -dates
    fi
  fi
}

# help:ssl-tool:Connects, downloads, converts, extracts or view certificate in multiple formats
ssl-tool ()
{
  local usage
  usage="ssl-tool view connect download convert extract check"
  case $1 in
    view|read)
        _ssl-tool_view $2 ;;
    connect|download)
        _ssl-tool_connect_download $@ ;;
    convert)
        _ssl-tool_convert $2 $3 ;;
    extract)
        _ssl-tool_extract $2 ;;
    check)
        _ssl-tool_check $2 $3 ;;
    *)
        echo "Unknown option"
        echo "$usage"
        return 1
        ;;
  esac
}

complete -W 'view read connect download convert extract check' ssl-tool

# To add

# Combine several certificates in PKCS7 (P7B) file:
# openssl crl2pkcs7 -nocrl -certfile child.crt -certfile ca.crt -out example.p7b


# -- Create
# Create Self-Signed Certificate
# openssl req -x509 -sha256 -nodes -newkey rsa:2048 -keyout gfselfsigned.key -out gfcert.pem
# Create new Private Key and Certificate Signing Request
# openssl req -out geekflare.csr -newkey rsa:2048 -nodes -keyout geekflare.key
# openssl req -x509 -sha256 -nodes -days 730 -newkey rsa:2048 -keyout gfselfsigned.key -out gfcert.pem
# Create RSA Private Key
# openssl genrsa -out private.key 2048
# Remove Passphrase from Key
# openssl rsa -in certkey.key -out nopassphrase.key
# Create CSR using existing private key
# openssl req -out certificate.csr -key existing.key -new

# -- Convert
# Convert PKCS12 format to PEM certificate
# openssl pkcs12 -in cert.p12 -out cert.pem

# -- Check
# Check Certificate Expiration Date of SSL URL
# openssl s_client -connect secureurl.com:443 2>/dev/null | openssl x509 -noout –enddate
