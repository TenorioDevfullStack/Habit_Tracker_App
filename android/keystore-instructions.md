# 🔐 INSTRUÇÕES PARA ASSINATURA DO APP

## 1. GERAR KEYSTORE (CHAVE ÚNICA DO SEU APP)

Execute no terminal:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Para Windows:
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Informações para preencher:

- **Senha do keystore:** (escolha uma senha FORTE e ANOTE)
- **Nome e sobrenome:** Seu nome completo
- **Unidade organizacional:** Nome da sua empresa/app
- **Organização:** Nome da empresa
- **Cidade:** Sua cidade
- **Estado:** Seu estado
- **Código do país:** BR
- **Senha da chave:** (mesma do keystore ou diferente)

⚠️ **IMPORTANTE:** Guarde estas senhas com segurança! Sem elas você não consegue atualizar o app!

## 2. CONFIGURAR ASSINATURA NO PROJETO

### Arquivo: android/key.properties

```
storePassword=SUA_SENHA_KEYSTORE
keyPassword=SUA_SENHA_CHAVE
keyAlias=upload
storeFile=C:/caminho/para/upload-keystore.jks
```

### Arquivo: android/app/build.gradle

```gradle
// Antes da seção android {
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... configurações existentes ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            shrinkResources false
            debuggable false
        }
    }
}
```

## 3. GERAR APK ASSINADO

```bash
flutter build apk --release
```

## 4. GERAR APP BUNDLE (RECOMENDADO PARA PLAY STORE)

```bash
flutter build appbundle --release
```

O arquivo será gerado em: `build/app/outputs/bundle/release/app-release.aab`
