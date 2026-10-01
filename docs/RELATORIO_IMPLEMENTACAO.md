# Relatório de implementação — PontoMobile

## 1. Introdução

O PontoMobile é um aplicativo Flutter acadêmico para demonstrar registro de ponto com autenticação, geolocalização, biometria local e persistência por usuário.

## 2. Objetivo do aplicativo

Permitir que uma pessoa autenticada registre entrada e saída quando o aparelho indicar que está a até 100 metros do local de trabalho configurado.

## 3. Tecnologias utilizadas

- Flutter e Dart.
- Firebase Core e Firebase Authentication.
- Cloud Firestore.
- Geolocator para GPS, permissões e distância.
- Local Auth para validação biométrica local.
- `flutter_test` para testes unitários e de widgets.

Nenhuma dependência nova foi adicionada.

## 4. Arquitetura do projeto

`core` contém validações, política de distância, configuração de coordenadas e tema. `models` contém perfil e registros. `services` encapsula Firebase e plugins de hardware. `screens` apresenta login, cadastro, ponto, histórico e perfil. `AppServices` compõe as dependências e permite testar widgets com repositórios falsos.

## 5. Autenticação

Firebase Authentication provê cadastro e login por e-mail/senha, estado persistente da sessão e logout. O cadastro cria o documento `users/{uid}` com nome, e-mail, data de criação do servidor e opção biométrica. A senha não é gravada no Firestore.

## 6. Biometria

Local Auth verifica suporte e biometria cadastrada. A confirmação biométrica protege localmente uma sessão já autenticada no Firebase; não emite credenciais Firebase e não armazena dados biométricos. O logout encerra a sessão Firebase e preserva a preferência biométrica do perfil; a ação **Sair e entrar com senha** na tela de bloqueio desativa essa preferência. O fluxo ainda precisa de teste físico em dispositivo compatível.

## 7. Geolocalização

Geolocator verifica se o serviço de localização está ativo, solicita permissão quando necessário e obtém posição com precisão alta e timeout de 20 segundos. Negativa de permissão, bloqueio permanente, GPS desligado, timeout e falhas de leitura resultam em mensagens amigáveis.

## 8. Regra dos 100 metros

O aplicativo usa coordenadas fixas do SENAI Americana: latitude `-22.7538572` e longitude `-47.3513785`, definidas em `lib/core/constants/app_config.dart`. A regra aceita distância menor ou igual a 100 m e bloqueia valores maiores.

## 9. Registro de ponto

O fluxo obtém uma localização nova ao confirmar o ponto, calcula a distância até o local configurado e só então grava `entrada` ou `saida`. A próxima ação alterna conforme o registro mais recente. O app desabilita submissões duplicadas enquanto grava.

## 10. Firestore

Perfis ficam em `users/{uid}`; registros ficam em `users/{uid}/records/{recordId}`. Cada registro inclui tipo, `recordedAt` do servidor, latitude, longitude e distância calculada no cliente. A tela de histórico acompanha snapshots em tempo real.

As regras restringem leitura ao proprietário e validam campos, horários e distância declarada. Foram compiladas pelo Firebase CLI e publicadas em `pontomobile-86dee` em 1º de outubro de 2026. Elas não autenticam a posição física enviada pelo dispositivo.

## 11. Interface e UX

A interface usa Material 3 e tema centralizado, navegação inferior para Ponto/Histórico/Perfil, cartões de localização e último registro, estados de carregamento e feedback de sucesso/erro. Login e cadastro validam os campos e evitam múltiplos envios.

## 12. Segurança

O código não armazena senha ou dados biométricos. Consultas são organizadas por UID e as regras impedem um usuário autenticado de ler/escrever documentos de outro UID. Coordenadas e distância ainda são fornecidas pelo cliente, que pode ser modificado; isso limita o uso como controle antifraude real.

## 13. Testes

Foram criados testes para configuração de coordenadas, raio de 100 m, sequência de registros, validação de formulário, serialização de perfil/registros, mensagens de erro, paths por UID e widgets de autenticação. Resultado final: `flutter analyze` sem problemas; `flutter test` com 24 testes aprovados; `flutter pub get` concluído; regras Firestore compiladas e publicadas; app compilado e iniciado no Android SM S908E sem coordenadas de trabalho.

## 14. Desafios encontrados

Na versão instalada do Cloud Firestore, `DocumentSnapshot.data()` não aceita parâmetro de opções para server timestamps. Para snapshots locais pendentes, os serviços fornecem um horário estimado apenas para exibição do registro ainda não confirmado; o documento salvo continua usando `FieldValue.serverTimestamp()` como horário oficial.

O build Android também reportou avisos dos plugins Firebase sobre o Kotlin Gradle Plugin e avisos Java de APIs/opções legadas. O Firebase CLI avisou que a chave `flutter` preexistente em `firebase.json` não faz parte do schema dele, mas concluiu o dry-run e o deploy das regras. O APK foi gerado e o app iniciou no emulador; esses avisos não foram ocultados nem alterados no código dos plugins/configuração FlutterFire.

## 15. Soluções adotadas

Foram mantidas as dependências já existentes. As chamadas Firebase e de hardware ficaram em serviços, regras simples ganharam testes puros, e erros externos são convertidos em mensagens compreensíveis. As coordenadas fixas foram fornecidas para o SENAI Americana.

## 16. Melhorias/diferenciais

- Indicador de distância/precisão e estado da localização.
- Próxima ação automática entre entrada e saída.
- Histórico detalhado em tempo real.
- Desbloqueio biométrico opcional da sessão autenticada.
- Perfis e registros segregados por UID.

## 17. Conclusão

O código local implementa os fluxos principais e a documentação de instalação. O Firestore já existe e as regras foram publicadas. Ainda é necessário confirmar o provedor E-mail/senha no Firebase Console e testar o fluxo com uma conta Firebase e GPS/biometria no Android. O app está fixado nas coordenadas do SENAI Americana.
