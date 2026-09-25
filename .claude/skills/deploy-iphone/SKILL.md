---
name: deploy-iphone
description: Gera um build release do forven_app e instala em um iPhone fisico conectado por USB ou Wi-Fi (ex.: "iPhone de Mario"), deixando o app independente do Mac para continuar testando apos desconectar. Use quando o usuario pedir para enviar, instalar, mandar ou testar o app no iPhone ou em um dispositivo iOS fisico.
---

# Deploy release em iPhone fisico

Faz build `--release` (AOT) e instala o `Runner.app` via `xcrun devicectl`, sem anexar debugger.
Como o app nao depende do `flutter run`, o usuario pode desconectar o cabo, sair da rede ou
fechar o terminal e continuar usando o app normalmente.

Motivo de nao usar `flutter run` em debug: no iOS 14+ builds debug nao abrem pelo icone
sem um debugger conectado. Build release nao tem essa limitacao.

## Passo 1 - Definir o dispositivo

Se o usuario ja informou o nome do dispositivo, use-o. Caso contrario:

1. Liste os dispositivos conhecidos pelo Xcode:
   `xcrun devicectl list devices`
2. Pergunte ao usuario qual dispositivo usar (use a ferramenta AskUserQuestion se disponivel),
   oferecendo os iPhones listados e sugerindo "iPhone de Mario" como padrao.

A busca pelo nome ignora maiusculas e acentos e aceita trecho do nome
("mario" encontra "iPhone de Mário").

## Passo 2 - Avisar sobre o ambiente da API

Antes de rodar, informe ao usuario em uma linha: o build release sempre usa a API de producao
(`https://console.forven.com.br`), pois `lib/services/api_config.dart` so aplica
`DEBUG_API_IP` em `kDebugMode`. Nao altere esse arquivo sem pedido explicito.

## Passo 3 - Executar o script

Na raiz do repositorio:

```bash
bash .claude/skills/deploy-iphone/scripts/deploy_iphone.sh "<nome do dispositivo>"
```

O build demora varios minutos: rode o comando Bash com timeout de 600000 ms.

Opcoes:
- `--clean` executa `flutter clean` antes do build (use se o build anterior estiver inconsistente).
- `--skip-build` reinstala o ultimo build existente em `build/ios/iphoneos/Runner.app`.
- `--no-launch` instala sem abrir o app.

O script usa `fvm flutter` quando o fvm esta instalado (versao definida em `.fvmrc`).

## Passo 4 - Interpretar o resultado

| Codigo | Significado | O que fazer |
|---|---|---|
| 0 | Instalado (e aberto, salvo `--no-launch`) | Informar que o usuario ja pode desconectar e testar. |
| 2 | Uso incorreto ou ambiente sem macOS/Xcode/Flutter | Mostrar a mensagem de erro. |
| 3 | Nenhum dispositivo com esse nome | Mostrar a lista impressa e perguntar novamente o nome. |
| 4 | Mais de um dispositivo corresponde | Mostrar as opcoes e pedir o nome exato. |
| 5 | Dispositivo nao pareado ou inacessivel | Ver "Problemas comuns". |
| 6 | Build nao encontrado | Rodar sem `--skip-build`. |
| 7 | Falha na instalacao | Ver "Problemas comuns". |
| outro | Erro do `flutter build` | Mostrar as ultimas linhas de erro; costuma ser assinatura. |

Se o app foi instalado mas nao abriu (aviso no final), o dispositivo provavelmente estava
bloqueado: basta abrir pelo icone.

## Problemas comuns

- **Wi-Fi nao encontra o iPhone:** o iPhone precisa ter sido pareado uma vez por USB, com
  "Connect via network" marcado em Xcode > Window > Devices and Simulators, estar na mesma
  rede do Mac e desbloqueado. Na duvida, conecte por USB para instalar e depois desconecte.
- **Developer Mode:** deve estar ativo em Ajustes > Privacidade e Seguranca > Modo de
  Desenvolvedor.
- **Erro de assinatura no build:** abrir `ios/Runner.xcworkspace` no Xcode, target Runner >
  Signing & Capabilities, conferir o Team. O dispositivo precisa estar no provisioning profile
  (com assinatura automatica o Xcode registra ao conectar).
- **Falha ao instalar sobre versao da App Store/TestFlight:** apagar o app do iPhone e rodar
  novamente com `--skip-build`.
- **"Desenvolvedor nao confiavel" ao abrir:** Ajustes > Geral > VPN e Gerenciamento de
  Dispositivos > confiar no certificado de desenvolvedor.

## Requisitos

macOS com Xcode 15 ou superior (para `devicectl`), Flutter/fvm configurados e `python3`.
