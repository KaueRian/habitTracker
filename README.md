# 🍃 Leve — Hábitos & Diário

**Leve** é um aplicativo Flutter para acompanhamento de hábitos e diário pessoal, com um design calmo e minimalista inspirado em bem-estar.

## ✨ Funcionalidades

- 📋 **Hábitos** — Crie, acompanhe e visualize seus hábitos diários
- 📓 **Diário** — Registre reflexões e pensamentos do dia a dia
- 📊 **Insights** — Gráficos e estatísticas sobre sua consistência
- 🧘 **Foco** — Modo de concentração com timer
- 👑 **Premium** — Assinatura via RevenueCat para recursos avançados
- 🔐 **Autenticação** — Login com Firebase Auth (e-mail/senha, anônimo)
- 🎨 **Temas sazonais** — Tropical, Primavera, Verão, Outono e Inverno

## 🛠️ Tecnologias

- [Flutter](https://flutter.dev/) 3.x
- [Riverpod](https://riverpod.dev/) — Gerenciamento de estado
- [Firebase](https://firebase.google.com/) — Auth + Firestore
- [Hive](https://docs.hivedb.dev/) — Persistência local
- [RevenueCat](https://www.revenuecat.com/) — Monetização / Assinaturas
- [fl_chart](https://pub.dev/packages/fl_chart) — Gráficos

## 🚀 Como rodar

### Pré-requisitos

- Flutter SDK ≥ 3.0.0
- Conta no [Firebase Console](https://console.firebase.google.com/)
- (Opcional) Conta no [RevenueCat](https://app.revenuecat.com/)

### 1. Clone o repositório

```bash
git clone https://github.com/SEU_USUARIO/leve.git
cd leve
```

### 2. Configure as variáveis de ambiente

```bash
cp .env.example .env
```

Abra o arquivo `.env` e preencha com as suas credenciais:

| Variável | Onde encontrar |
|---|---|
| `FIREBASE_WEB_API_KEY` | Firebase Console → Configurações → Apps → Web |
| `FIREBASE_WEB_APP_ID` | Firebase Console → Configurações → Apps → Web |
| `FIREBASE_WEB_MESSAGING_SENDER_ID` | Firebase Console → Configurações → Geral |
| `FIREBASE_WEB_PROJECT_ID` | Firebase Console → Configurações → Geral |
| `FIREBASE_WEB_AUTH_DOMAIN` | Firebase Console → Configurações → Apps → Web |
| `FIREBASE_WEB_STORAGE_BUCKET` | Firebase Console → Configurações → Geral |
| `FIREBASE_ANDROID_API_KEY` | Firebase Console → Configurações → Apps → Android |
| `FIREBASE_ANDROID_APP_ID` | Firebase Console → Configurações → Apps → Android |
| `FIREBASE_ANDROID_MESSAGING_SENDER_ID` | Firebase Console → Configurações → Geral |
| `FIREBASE_ANDROID_PROJECT_ID` | Firebase Console → Configurações → Geral |
| `FIREBASE_ANDROID_STORAGE_BUCKET` | Firebase Console → Configurações → Geral |
| `REVENUECAT_ANDROID_API_KEY` | RevenueCat Dashboard → API Keys |
| `REVENUECAT_ENTITLEMENT_ID` | RevenueCat Dashboard → Entitlements → Identifier |

### 3. Configure o Firebase para Android

Baixe o arquivo `google-services.json` do Firebase Console e coloque em:

```
android/app/google-services.json
```

> ⚠️ Este arquivo contém credenciais e **não** é commitado no repositório.

### 4. Instale as dependências

```bash
flutter pub get
```

### 5. Execute o app

```bash
# Android
flutter run

# Web
flutter run -d chrome
```

> 💡 Se o Firebase não estiver configurado, o app rodará em **modo simulado** (guest mode) para fins de desenvolvimento.

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                  # Ponto de entrada
├── app.dart                   # Widget raiz (MaterialApp)
├── firebase_options.dart      # Config Firebase (lê do .env)
├── shared/
│   ├── navigation_shell.dart  # Barra de navegação
│   └── storage_service.dart   # Persistência local (Hive)
├── features/
│   ├── auth/                  # Login, cadastro, auth provider
│   ├── habits/                # Tela principal, criação de hábitos
│   ├── journal/               # Diário
│   ├── insights/              # Gráficos e estatísticas
│   ├── focus/                 # Timer de foco
│   ├── premium/               # Paywall, config RevenueCat
│   └── settings/              # Configurações, temas
└── theme/                     # Temas e paletas de cores
```

## 🔒 Segurança

- **Credenciais** são carregadas de variáveis de ambiente (`.env`) via `flutter_dotenv`
- O arquivo `.env` está no `.gitignore` e **nunca** é commitado
- O arquivo `google-services.json` está no `.gitignore` e **nunca** é commitado
- Use o `.env.example` como referência para configurar suas próprias credenciais

## 📄 Licença

Este projeto é de uso acadêmico / pessoal.
