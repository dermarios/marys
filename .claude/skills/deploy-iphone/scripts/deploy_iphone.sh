#!/usr/bin/env bash
# Gera build release do forven_app e instala em um iPhone fisico (USB ou Wi-Fi).
# O app instalado roda sem debugger, entao o dispositivo pode ser desconectado.
#
# Uso:
#   deploy_iphone.sh "<nome do dispositivo>" [--clean] [--skip-build] [--no-launch]
#
# Codigos de saida:
#   0 sucesso | 2 uso/ambiente | 3 dispositivo nao encontrado | 4 nome ambiguo
#   5 nao pareado/inacessivel | 6 build ausente | 7 falha na instalacao
set -euo pipefail

fail() {
  echo "ERRO: $1" >&2
  exit "${2:-1}"
}

DEVICE_QUERY=""
CLEAN=0
SKIP_BUILD=0
LAUNCH=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean) CLEAN=1 ;;
    --skip-build) SKIP_BUILD=1 ;;
    --no-launch) LAUNCH=0 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    -*) fail "opcao desconhecida: $1" 2 ;;
    *)
      if [[ -z "$DEVICE_QUERY" ]]; then
        DEVICE_QUERY="$1"
      else
        fail "argumento extra: $1 (use aspas no nome do dispositivo)" 2
      fi
      ;;
  esac
  shift
done

[[ -n "$DEVICE_QUERY" ]] || fail "informe o nome do dispositivo. Ex.: deploy_iphone.sh \"iPhone de Mario\"" 2

# --- Ambiente ---------------------------------------------------------------
[[ "$(uname -s)" == "Darwin" ]] || fail "este script precisa rodar no macOS." 2
xcrun --find devicectl >/dev/null 2>&1 || fail "devicectl indisponivel. Requer Xcode 15 ou superior." 2
command -v python3 >/dev/null 2>&1 || fail "python3 nao encontrado." 2

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
elif command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter)
else
  fail "nem fvm nem flutter encontrados no PATH." 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)" || fail "repositorio git nao encontrado." 2
[[ -f "$REPO_ROOT/pubspec.yaml" ]] || fail "pubspec.yaml nao encontrado em $REPO_ROOT." 2
cd "$REPO_ROOT"

# --- Localizar dispositivo -------------------------------------------------
DEVICES_JSON="$(mktemp -t forven_devices)"
trap 'rm -f "$DEVICES_JSON"' EXIT

echo "Procurando dispositivo \"$DEVICE_QUERY\"..."
xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null 2>&1 \
  || fail "falha ao listar dispositivos (xcrun devicectl list devices)." 1

set +e
MATCH="$(python3 - "$DEVICES_JSON" "$DEVICE_QUERY" <<'PY'
import json
import sys
import unicodedata


def norm(value):
    value = unicodedata.normalize("NFKD", value or "")
    value = "".join(c for c in value if not unicodedata.combining(c))
    value = value.replace("\u2019", "'")
    return " ".join(value.lower().split())


path, query = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as fh:
    data = json.load(fh)

devices = []
for dev in (data.get("result") or {}).get("devices") or []:
    hw = dev.get("hardwareProperties") or {}
    if hw.get("platform") not in (None, "iOS"):
        continue
    props = dev.get("deviceProperties") or {}
    conn = dev.get("connectionProperties") or {}
    devices.append({
        "id": dev.get("identifier") or hw.get("udid") or "",
        "name": props.get("name") or "",
        "os": props.get("osVersionNumber") or "?",
        "transport": conn.get("transportType") or "-",
        "tunnel": conn.get("tunnelState") or "-",
        "pairing": conn.get("pairingState") or "-",
    })


def describe(items):
    if not items:
        return "  (nenhum dispositivo iOS conhecido pelo Xcode)"
    return "\n".join(
        f"  - {d['name']} | iOS {d['os']} | conexao={d['transport']} | "
        f"tunel={d['tunnel']} | pareamento={d['pairing']}"
        for d in items
    )


q = norm(query)
exact = [d for d in devices if norm(d["name"]) == q]
partial = [d for d in devices if q in norm(d["name"])]
found = exact or partial

if not found:
    print(f"Nenhum dispositivo corresponde a '{query}'. Dispositivos conhecidos:\n"
          f"{describe(devices)}", file=sys.stderr)
    sys.exit(3)
if len(found) > 1:
    print(f"Mais de um dispositivo corresponde a '{query}':\n{describe(found)}",
          file=sys.stderr)
    sys.exit(4)

d = found[0]
if not d["id"]:
    print("Dispositivo encontrado sem identificador.", file=sys.stderr)
    sys.exit(3)
print("\t".join([d["id"], d["name"], d["transport"], d["tunnel"], d["pairing"]]))
PY
)"
RC=$?
set -e
[[ $RC -eq 0 ]] || exit "$RC"

IFS=$'\t' read -r DEVICE_ID DEVICE_NAME TRANSPORT TUNNEL PAIRING <<<"$MATCH"
echo "Dispositivo: $DEVICE_NAME (conexao=$TRANSPORT, tunel=$TUNNEL)"

if [[ "$PAIRING" != "paired" && "$PAIRING" != "-" ]]; then
  fail "\"$DEVICE_NAME\" nao esta pareado com este Mac. Conecte por USB, toque em 'Confiar' no iPhone e abra Xcode > Window > Devices and Simulators." 5
fi
if [[ "$TUNNEL" == "unavailable" ]]; then
  fail "\"$DEVICE_NAME\" nao esta acessivel agora. Para Wi-Fi: mesma rede do Mac, iPhone desbloqueado e 'Connect via network' marcado no Xcode. Ou conecte por USB." 5
fi

# --- Build ------------------------------------------------------------------
APP_PATH="$REPO_ROOT/build/ios/iphoneos/Runner.app"

if [[ $SKIP_BUILD -eq 0 ]]; then
  if [[ $CLEAN -eq 1 ]]; then
    echo "Executando flutter clean..."
    "${FLUTTER[@]}" clean
  fi
  echo "Executando pub get..."
  "${FLUTTER[@]}" pub get
  echo "Gerando build iOS release (pode levar alguns minutos)..."
  "${FLUTTER[@]}" build ios --release
else
  echo "Pulando build (--skip-build)."
fi

[[ -d "$APP_PATH" ]] || fail "build nao encontrado em $APP_PATH. Rode sem --skip-build." 6
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Info.plist")"
APP_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Info.plist" 2>/dev/null || echo '?')"
APP_BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PATH/Info.plist" 2>/dev/null || echo '?')"

# --- Instalar ---------------------------------------------------------------
echo "Instalando $BUNDLE_ID ($APP_VERSION+$APP_BUILD) em \"$DEVICE_NAME\"..."
xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH" \
  || fail "falha ao instalar em \"$DEVICE_NAME\". Verifique se o iPhone esta desbloqueado e com Developer Mode ativo. Se o app veio da App Store/TestFlight, apague-o e rode novamente com --skip-build." 7

# --- Abrir ------------------------------------------------------------------
if [[ $LAUNCH -eq 1 ]]; then
  echo "Abrindo o app..."
  if ! xcrun devicectl device process launch --device "$DEVICE_ID" --terminate-existing "$BUNDLE_ID" >/dev/null; then
    echo "AVISO: app instalado, mas nao foi possivel abri-lo automaticamente (iPhone bloqueado?). Abra pelo icone." >&2
  fi
fi

echo ""
echo "Concluido: build release $APP_VERSION+$APP_BUILD instalado em \"$DEVICE_NAME\"."
echo "O app roda sem debugger: o iPhone ja pode ser desconectado do cabo ou da rede."
echo "Observacao: build release usa a API de producao (console.forven.com.br)."
