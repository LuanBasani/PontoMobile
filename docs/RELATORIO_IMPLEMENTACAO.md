# Relatório de implementação — PontoMobile

| Controle do documento | Informação |
|---|---|
| Identificação | DOC-03 |
| Versão | 1.0 |
| Revisão | 2026-10-01 |
| Natureza | Projeto acadêmico — Recursos de Hardware |
| Escopo | Aplicativo Android Flutter para registro de ponto com Firebase, localização e biometria local |

Este relatório registra a implementação presente no repositório. Configurações remotas e verificações em hardware são identificadas como pendências quando não podem ser confirmadas pelo código local.

## 1. Introdução

O PontoMobile é um aplicativo Android desenvolvido em Flutter para demonstrar registro de entrada e saída com autenticação, geolocalização, persistência individual e desbloqueio biométrico local opcional.

## 2. Objetivo do aplicativo

Permitir que uma pessoa autenticada registre ponto quando a posição informada pelo aparelho estiver a até 100 metros do local de trabalho configurado. Os eventos são armazenados no Firestore associados ao UID da conta.

## 3. Tecnologias utilizadas

- Flutter e Dart para interface e lógica do aplicativo.
- Firebase Core para inicialização do Firebase.
- Firebase Authentication para cadastro, login e estado da sessão.
- Cloud Firestore para perfil e registros de ponto.
- Geolocator para permissões, posição e cálculo de distância.
- Local Auth para confirmação biométrica local.
- flutter_test para testes unitários e de widgets.

As dependências estão declaradas em pubspec.yaml; esta implementação não adiciona dependências além das existentes.

## 4. Arquitetura do projeto

main.dart inicializa o Firebase e compõe os serviços. app/ reúne a composição e contratos de serviço. core/ centraliza configuração, política de presença, validação de formulário e tema. models/ contém perfil e registro. services/ encapsula Firebase e APIs do dispositivo. screens/ contém autenticação, ponto, histórico e perfil. firestore.rules contém as regras locais; test/ contém testes sem dependência de serviços reais.

## 5. Autenticação

Firebase Authentication oferece cadastro e login com e-mail e senha e mantém o estado da sessão. O cadastro grava nome, e-mail, data do servidor e preferência biométrica inicial em users/{uid}. A senha não é armazenada pelo app no Firestore. O Auth Gate decide entre login, desbloqueio biométrico, conteúdo autenticado e estados de erro conforme a sessão e o perfil.

## 6. Biometria

Local Auth verifica suporte e biometria cadastrada e solicita confirmação local. A opção é armazenada como biometricEnabled no perfil do Firestore. Quando ativa, o app bloqueia o conteúdo ao iniciar ou retomar a sessão e solicita confirmação. O logout comum preserva a preferência; **Sair e entrar com senha** na tela de bloqueio desativa a preferência e encerra a sessão. A biometria não cria credencial Firebase nem armazena dados biométricos.

## 7. Geolocalização

O serviço de localização verifica disponibilidade do GPS, solicita permissão, consulta a posição com alta precisão e usa timeout de 20 segundos. Erros como permissão negada, serviço desativado, timeout e falha de leitura são convertidos em mensagens para a interface.

## 8. Regra dos 100 metros

O local configurado é a Escola SENAI "Prof. João Baptista Salles da Silva", Americana, nas coordenadas -22.7538572, -47.3513785, informadas pelo responsável do projeto e centralizadas em AppConfig. AttendancePolicy permite distâncias finitas entre 0 e 100 metros, inclusive. Valores maiores ou inválidos são recusados.

## 9. Registro de ponto

Ao confirmar o registro, o app consulta uma posição atual, calcula a distância, valida coordenadas e raio e então grava Entrada ou Saída. A ação seguinte é determinada pelo evento mais recente. O botão é bloqueado enquanto uma submissão está em andamento. A interface atualiza a localização e apresenta confirmação ou erro.

## 10. Firestore

Perfis são armazenados em users/{uid} e registros em users/{uid}/records/{recordId}. Os registros guardam tipo, recordedAt, latitude, longitude e distância. O serviço consulta o histórico em ordem decrescente e acompanha atualizações por stream. O horário gravado usa FieldValue.serverTimestamp().

O arquivo local firestore.rules restringe o acesso ao proprietário e valida o formato e a distância declarada. O estado de publicação das regras no projeto remoto deve ser confirmado no Console ou pelo Firebase CLI; não é inferido apenas pela presença do arquivo.

## 11. Interface e experiência de uso

A interface utiliza Material 3 e navegação inferior entre Ponto, Histórico e Perfil. A tela Ponto apresenta distância, localização, próxima ação e registro mais recente. Login e cadastro incluem validação, estado de carregamento e mensagens amigáveis. Histórico atualiza por stream do Firestore.

## 12. Segurança

Senhas e dados biométricos não são armazenados pelo aplicativo. Consultas e regras são organizadas por UID autenticado. A chave de API presente na configuração FlutterFire é um identificador cliente Firebase, não uma credencial de autorização; a segurança dos dados depende das regras e dos controles Firebase. O responsável deve confirmar no Console as restrições de API da chave e a configuração dos serviços.

As coordenadas, a distância e o limite são processados no cliente e não comprovam presença física. As regras impedem acessos entre UIDs, mas não impedem por si só que um cliente modificado envie uma posição falsa. O projeto não deve ser tratado como sistema antifraude ou ponto trabalhista de produção sem validação confiável em servidor e revisão legal/privacidade.

## 13. Testes

A suíte automatizada cobre configuração fixa, limite inclusivo e excedente, sequência de eventos, validadores, serialização dos modelos, mapeamento de erros, paths Firestore e widgets de autenticação e bloqueio biométrico. Os testes não comprovam a configuração da nuvem, GPS físico ou sensor biométrico; estes requerem validação manual.

Comandos de verificação:

~~~bash
flutter analyze
flutter test
~~~

Verificação executada em 2026-10-01: flutter analyze terminou sem problemas e flutter test aprovou 24 testes. Esses resultados não comprovam o estado dos serviços Firebase remotos nem o funcionamento de hardware físico.

## 14. Desafios encontrados

Não há registro de evidência suficiente para afirmar outros incidentes de implementação. Considerações técnicas identificadas: a chave Firebase de cliente é pública por natureza e deve ter uso restrito; coordenadas recebidas do dispositivo não são prova confiável de presença; o sensor biométrico do emulador precisa ser configurado para validação manual.

## 15. Soluções adotadas

Foram usados serviços para isolar integrações Firebase e de hardware, regras de domínio puras para distância e sequência de ponto, validadores reutilizáveis e testes sem dependência de serviços remotos. A configuração de coordenadas foi centralizada. Não foram adicionadas dependências para gerar documentação ou esconder a configuração pública Firebase.

## 16. Melhorias e diferenciais

- Feedback de disponibilidade, distância e precisão da localização.
- Alternância automática de Entrada e Saída.
- Histórico individual atualizado em tempo real.
- Desbloqueio local opcional da sessão autenticada.
- Tratamento de erros de autenticação, GPS e gravação.
- Regras locais do Firestore e testes de paths associados ao UID.

## 17. Conclusão

O repositório contém a implementação Flutter, testes, regras locais e documentação para o fluxo acadêmico de registro de ponto. Antes de uma demonstração, devem ser confirmados no ambiente Firebase o provedor E-mail/senha, a disponibilidade do Firestore e a publicação das regras. GPS e biometria devem ser verificados no dispositivo ou emulador usado na apresentação. Essas verificações externas não são declaradas como concluídas por este relatório.
