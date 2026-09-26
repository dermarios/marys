# Atualização — botão "expandir" no mini player

Arquivo: `lib/widgets/mini_player.dart` (substitua o arquivo inteiro **ou** aplique os 3 trechos abaixo).

## 1. Import
No topo do arquivo, adicione:
```dart
import 'dart:ui';
```

## 2. `PlayerShell.build` — dentro do `Stack`, logo depois do `Positioned` do `MiniPlayer`
```dart
if (audioService.currentTrack != null)
  Positioned(
    left: 0,
    right: 0,
    bottom: MediaQuery.of(context).padding.bottom + 8 + 64 - 8,
    child: Center(
      child: BotaoExpandir(
        onTap: () => Navigator.of(context).push(rotaPlayerExpandido(audioService)),
      ),
    ),
  ),
```
Os 8 px descontados encaixam a pílula na borda superior do mini player (altura 64). Como vem depois no `Stack`, ela é pintada por cima.

## 3. Novo widget — cole no fim do arquivo
Copie a classe `BotaoExpandir` (e o `_BotaoExpandirState`) do `mini_player.dart` deste pacote.

- Visual: pílula de vidro de 36×20 com borda clara e uma seta que sobe e desce 1,5 px.
- A área de toque tem 8 px de folga em volta, porque a pílula sozinha é pequena demais para o dedo.
- Tem `Semantics(label: 'Expandir player')` para acessibilidade.

Nenhuma outra tela muda.
