# Atualização — mini player expansível (nova abordagem)

Arquivo: `lib/widgets/mini_player.dart` — **substitua o arquivo inteiro**. A mudança é estrutural (o `PlayerShell` passou a ter estado), por isso não dá para aplicar por trechos.

A pílula "expandir" da versão anterior foi **removida**.

## O que mudou

1. **Alça no topo do mini player** — barrinha de 36×4 px, no padrão dos painéis do iOS. O mini player passou de 64 para 70 px de altura para caber a alça.
2. **Arrastar para expandir** — o player expandido sobe acompanhando o dedo e o mini player some aos poucos. Abre se passar de 90 px ou se o gesto for rápido para cima; senão, volta. Um toque simples continua abrindo.
3. **Dica de primeira vez** — 1,4 s depois de montar, o mini player quica duas vezes, a alça acende e aparece o balão *"Deslize para ver letra, clipe e mais"* por cerca de 3 s.
   - Aparece no máximo 3 vezes (`PlayerShell.vezesDica`).
   - Depois que o usuário expande uma vez, nunca mais aparece.

## Dependência nova

A dica guarda quantas vezes já foi vista:

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.3.0
```

```bash
flutter pub get
```

## Uso

Não muda — continue envolvendo as telas com `PlayerShell`:

```dart
PlayerShell(
  audioService: audioService,
  child: LibraryScreen(audioService: audioService),
)
```

## Testar a dica de novo

Para ver a dica outra vez durante o desenvolvimento, apague as chaves:

```dart
final p = await SharedPreferences.getInstance();
await p.remove('mini_hint_vistas');
await p.remove('mini_hint_expandiu');
```

## Observação

Durante o arrasto, a prévia monta uma `LiquidPlayerScreen` real por baixo do dedo. Se ficar pesado em aparelhos mais simples, troque essa prévia por um `Container` com o fundo líquido.
