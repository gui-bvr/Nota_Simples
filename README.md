<img src="/Users/guilhermeviana/Documents/Flutter Projects/projeto_tcc/assets/logo/logo.webp" alt="logo" style="zoom:15%;" />

<p align="center"><strong>Nota Simples</strong></p>

<p align="center">Aplicativo de gerenciamento de notas fiscais. </p>



## Descrição

Este projeto faz parte do meu portfólio para o curso de Engenharia de Software. O sistema foi criado para atender a uma demanda real de comerciantes que enfrentam dificuldades na emissão e visualização de notas fiscais ao longo do dia.

O aplicativo tem como objetivo oferecer uma solução eficiente para organizar, monitorar e facilitar o acesso às notas fiscais emitidas, garantindo mais controle sobre as transações realizadas. Com uma interface intuitiva e recursos voltados à praticidade, o sistema permite que os comerciantes consultem rapidamente as notas emitidas, reduzindo erros e otimizando a gestão financeira do estabelecimento.

A aplicação foi desenvolvida com uma arquitetura escalável, permitindo sua adaptação para desktops com MacOS, Windows e Linux. No entanto, a prioridade foi garantir praticidade para dispositivos móveis, considerando a necessidade dos comerciantes de acessar as informações de forma rápida e em qualquer lugar.

Além disso, a aplicação facilita a exportação e o envio das notas fiscais para escritórios de contabilidade ou sistemas ERP, proporcionando maior integração e eficiência na gestão fiscal e contábil.



## Tecnologias Utilizadas

### **Tecnologias Principais**:

- **Linguagem:** Dart
- **Framework:** Flutter
- **Banco de Dados:** SQLite e Firebase (Cloud)
- **Arquitetura:** Modular, seguindo princípios de **Clean Code**
- **Machine Learning:** Firebase ML (em fase de testes)
- **Testes:** flutter_test
- **Gerenciamento de Estado:** GetX

### 

## Restrições

O aplicativo possui algumas restrições até o momento:

- **Compatibilidade Testada:** O aplicativo foi testado e validado em um emulador de um iPhone 16 Pro Max e em um computador com o sistema operacional **Windows 7 Ultimate**. Apesar de o Windows 7 não possuir mais suporte oficial da Microsoft, a aplicação funcionou corretamente com a integração. No entanto, **não é possível oferecer suporte para essa plataforma**.

- **Limitação Geográfica:** Devido às **diferenças nos sistemas de emissão fiscal entre os estados do Brasil**, a aplicação depende do **SAT (Sistema Autenticador e Transmissor de Cupons Fiscais Eletrônicos)**, um equipamento obrigatório em pontos de venda (PDVs) de alguns estados. A aplicação foi testada com sucesso em um comércio no estado de **São Paulo**, mas sua compatibilidade com outros estados que adotam o **SAT** pode variar. Os estados que utilizam essa tecnologia são:

  - **Alagoas**
  - **Ceará**
  - **Mato Grosso**
  - **Minas Gerais**
  - **Paraná**
  - **Sergipe**

  Caso o usuário esteja em um desses estados, é recomendado verificar a compatibilidade do equipamento SAT antes de utilizar o aplicativo.

- **Incompatibilidade com NFC-e:** **Até o momento, o aplicativo não oferece suporte para NFC-e (Nota Fiscal de Consumidor Eletrônica)**, pois o **consumo de dados de exportação é muito elevado**, o que pode impactar a experiência do usuário e o desempenho do sistema.

  

## Requisitos de Software

### Requisitos Funcionais:

**RF01:** A aplicação deve permitir o cadastro de usuários.

**RF02:** A aplicação deve permitir o login de usuários cadastrados com autenticação **Firebase Authentication**.

**RF03:** A aplicação deve permitir que o usuário delete sua conta.

**RF04:** A aplicação deve permitir que o usuário encerre sua sessão.

**RF05:** A aplicação deve fazer um backup local antes do envio para a nuvem (caso o usuario deseje).

**RF06:** A aplicação deve exportar as notas fiscais para o formato padrão do SAT (.XML).



### Requisitos Não Funcionais:

**RNF01:** A aplicação deve garantir a segurança dos dados do usuário.

**RNF02:** A aplicação deve ter um bom desempenho.

**RNF03:** A aplicação deve ter uma interface intuitiva e fácil de utilizar.

**RNF04:** A aplicação deve ser modular e bem arquitetada, permitindo atualizações futuras e fácil manutenção.

**RNF05:** A aplicação deve apresentar testes unitários.

**RNF06:** A aplicação deve aumentar o suporte para outros estados em breve.



## Desenvolvedor

Esse software foi desenvolvido por Guilherme Banzati Viana Ribeiro, e esta protegido pela licença Creative Commons Attribution-NonCommercial-NoDerivatives (CC BY-NC-ND).
