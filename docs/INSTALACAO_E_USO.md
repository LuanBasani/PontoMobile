# Instalação e uso do PontoMobile

## 1. Pré-requisitos

- Flutter e Dart compatíveis com as versões declaradas em `pubspec.yaml` (Dart `^3.12.2`).
- Android Studio com Android SDK e um emulador ou aparelho Android.
- Firebase CLI e FlutterFire CLI para administrar o Firebase.
- Um local de trabalho conhecido e autorização para usar suas coordenadas.

O projeto está configurado para Android. `lib/firebase_options.dart` contém configuração apenas para Android.

## 2. Abrir o projeto

Abra a pasta `ponto_mobile` no Android Studio ou VS Code. No terminal, entre nessa pasta e baixe/resolva as dependências já declaradas:

```bash
flutter pub get
```

## 3. Firebase

O projeto local já referencia o projeto Firebase `pontomobile-86dee`, o app Android `com.example.ponto_mobile` e contém `android/app/google-services.json`. Não execute `flutterfire configure` sem necessidade; isso pode alterar os arquivos gerados existentes.

No Firebase Console, confirme ou faça manualmente:

1. Abra Authentication → Sign-in method e confirme que **E-mail/senha** está habilitado.
2. O Firebase CLI confirmou o banco Cloud Firestore `(default)` na região `southamerica-east1` em 1º de outubro de 2026.
3. As regras locais foram compiladas e publicadas no projeto em 1º de outubro de 2026. Para republicá-las após alterações:

   ```bash
   firebase deploy --only firestore:rules --project pontomobile-86dee
   ```

As regras em `firestore.rules` permitem que cada usuário acesse apenas `users/{uid}` e seus próprios documentos em `users/{uid}/records`. Elas já foram publicadas no projeto configurado. As regras restringem usuários e valores declarados, mas não comprovam que as coordenadas GPS do cliente são autênticas.

## 4. Coordenadas do trabalho

## 4. Coordenadas fixas do trabalho

O aplicativo está configurado para o SENAI Americana (Escola SENAI "Prof. João Baptista Salles da Silva") com estas coordenadas:

- Latitude: `-22.7538572`
- Longitude: `-47.3513785`

Esses valores ficam fixos em `lib/core/constants/app_config.dart`; não é necessário informar `--dart-define` ao executar. Para usar outro local, atualize as constantes nesse arquivo e o teste em `test/core/app_config_test.dart`.

## 5. Permissões e biometria no Android

O manifesto inclui `ACCESS_COARSE_LOCATION`, `ACCESS_FINE_LOCATION` e `USE_BIOMETRIC`. O aplicativo pede localização em tempo de execução. Ative o serviço de localização do aparelho para registrar o ponto.

Para testar biometria, configure impressão digital ou reconhecimento facial nas configurações do aparelho. No emulador, configure uma biometria virtual compatível. A versão instalada de Local Auth usa `FlutterFragmentActivity` em `MainActivity`.

Depois de entrar por e-mail/senha, abra a aba Perfil e habilite **Desbloquear com biometria**. A preferência fica salva no perfil mesmo após sair da conta; ao entrar novamente, o app solicitará a confirmação biométrica. Na tela de bloqueio, **Sair e entrar com senha** desativa a preferência para permitir acesso sem biometria. A biometria não recupera nem substitui a senha.

## 6. Executar

Com um dispositivo conectado ou emulador iniciado:

```bash
flutter run
```

Crie uma conta com nome, e-mail e senha. O perfil é armazenado em `users/{uid}`. Na tela Ponto, atualize a localização. O registro só fica habilitado quando a distância calculada está dentro de 100 metros; cada novo evento alterna entre Entrada e Saída. Os registros incluem data/hora do servidor, latitude, longitude e distância calculada no cliente.

## 7. Análise e testes

```bash
flutter analyze
flutter test
```

Não é necessário Firebase real para os testes unitários e de widget existentes.

## 8. Problemas comuns

- **Permissão negada:** autorize localização nas configurações do aplicativo; quando negada permanentemente, o sistema pode exigir ajuste manual.
- **GPS desligado ou localização indisponível:** ative localização e tente novamente ao ar livre.
- **Erro ao cadastrar ou entrar:** confira conexão e provedor E-mail/senha no Firebase Console.
- **Erro de Firestore/permissão:** confirme a conta, o projeto selecionado e as regras publicadas no Firebase correto.
- **Biometria indisponível:** configure biometria no aparelho ou entre com e-mail e senha.
- **Nenhum dispositivo encontrado por `flutter run`:** inicie um emulador Android ou conecte um dispositivo com depuração USB habilitada.

## 9. Limites conhecidos

A checagem de distância e as coordenadas vêm do cliente. Regras Firestore podem limitar usuários e valores declarados, mas não provam a autenticidade da posição física. Para uso trabalhista em produção, a geolocalização precisaria ser validada por uma API confiável e protegida contra falsificação. O horário usa `serverTimestamp` do Firestore.
