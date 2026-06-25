import 'package:flutter/material.dart';

enum TipoInformacaoApp {
  sobre,
  ajuda,
  privacidade,
  checklist,
}

class InformacoesAppScreen extends StatelessWidget {
  final TipoInformacaoApp tipo;

  const InformacoesAppScreen({
    super.key,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final conteudo = _conteudo(tipo);

    return Scaffold(
      appBar: AppBar(title: Text(conteudo.titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hero(context, conteudo),
            const SizedBox(height: 18),
            ...conteudo.secoes.map((secao) => _secao(context, secao)),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, _ConteudoInformacao conteudo) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(conteudo.icon, color: colorScheme.primary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            conteudo.titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            conteudo.subtitulo,
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _secao(BuildContext context, _SecaoInformacao secao) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(secao.icon, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  secao.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...secao.itens.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  _ConteudoInformacao _conteudo(TipoInformacaoApp tipo) {
    switch (tipo) {
      case TipoInformacaoApp.sobre:
        return _ConteudoInformacao(
          titulo: "Sobre o IJob",
          subtitulo:
              "Uma plataforma mobile para conectar clientes a prestadores próximos, com localização real e controle de agendamentos.",
          icon: Icons.info,
          secoes: [
            _SecaoInformacao(
              titulo: "Objetivo do app",
              icon: Icons.flag,
              itens: [
                "Facilitar a busca por profissionais de serviços locais.",
                "Permitir que o cliente encontre prestadores que atendem sua região.",
                "Dar ao prestador uma agenda simples para aceitar, iniciar e concluir atendimentos.",
              ],
            ),
            _SecaoInformacao(
              titulo: "Tecnologias usadas",
              icon: Icons.code,
              itens: [
                "Flutter para interface mobile.",
                "Firebase Authentication para login e recuperação de senha.",
                "Cloud Firestore para cadastro de prestadores e agendamentos.",
                "Google Maps e localização real para mapa e área de atendimento.",
              ],
            ),
          ],
        );
      case TipoInformacaoApp.ajuda:
        return _ConteudoInformacao(
          titulo: "Ajuda",
          subtitulo:
              "Entenda como usar as principais funções do IJob durante a demonstração.",
          icon: Icons.help,
          secoes: [
            _SecaoInformacao(
              titulo: "Como funciona o agendamento",
              icon: Icons.calendar_month,
              itens: [
                "O cliente escolhe prestador, data, horário e envia a solicitação.",
                "O prestador recebe o pedido e decide se aceita ou recusa com justificativa.",
                "Após aceitar, o prestador pode iniciar e concluir o atendimento.",
              ],
            ),
            _SecaoInformacao(
              titulo: "Como funciona a localização",
              icon: Icons.location_on,
              itens: [
                "O app pede permissão para usar a localização real do usuário.",
                "A distância é usada para mostrar prestadores próximos.",
                "O mapa mostra o prestador, o cliente e o raio de atendimento.",
              ],
            ),
            _SecaoInformacao(
              titulo: "Conta e senha",
              icon: Icons.lock,
              itens: [
                "O usuário pode editar nome, telefone e localização em Configurações.",
                "A senha pode ser alterada ou recuperada por e-mail.",
                "Prestadores também podem editar serviço, agenda, fotos e WhatsApp.",
              ],
            ),
          ],
        );
      case TipoInformacaoApp.privacidade:
        return _ConteudoInformacao(
          titulo: "Privacidade",
          subtitulo:
              "Resumo simples sobre como o IJob usa dados como localização, telefone e fotos.",
          icon: Icons.privacy_tip,
          secoes: [
            _SecaoInformacao(
              titulo: "Dados usados",
              icon: Icons.dataset,
              itens: [
                "Nome, e-mail e telefone são usados para identificação da conta.",
                "Fotos ajudam clientes e prestadores a reconhecer perfis e trabalhos realizados.",
                "Localização é usada para calcular distância e área de atendimento.",
              ],
            ),
            _SecaoInformacao(
              titulo: "Transparência",
              icon: Icons.visibility,
              itens: [
                "A localização só é usada quando o usuário permite.",
                "O telefone do prestador pode ser usado para abrir conversa no WhatsApp.",
                "O app foi desenvolvido para fins acadêmicos e demonstração de TCC.",
              ],
            ),
          ],
        );
      case TipoInformacaoApp.checklist:
        return _ConteudoInformacao(
          titulo: "Checklist da banca",
          subtitulo:
              "Roteiro rápido para testar o app antes da apresentação final.",
          icon: Icons.fact_check,
          secoes: [
            _SecaoInformacao(
              titulo: "Fluxo do cliente",
              icon: Icons.person,
              itens: [
                "Criar conta ou entrar como cliente.",
                "Permitir localização ao abrir o app.",
                "Buscar prestador, abrir perfil e visualizar mapa real.",
                "Enviar solicitação de agendamento com observação.",
                "Acompanhar status em Meus serviços e avaliar após conclusão.",
              ],
            ),
            _SecaoInformacao(
              titulo: "Fluxo do prestador",
              icon: Icons.work,
              itens: [
                "Entrar como prestador cadastrado.",
                "Editar serviço, fotos, WhatsApp, frases, agenda e raio de atendimento.",
                "Receber solicitação, aceitar ou recusar com justificativa.",
                "Iniciar atendimento, concluir e visualizar agenda da semana.",
              ],
            ),
            _SecaoInformacao(
              titulo: "Pontos para mostrar",
              icon: Icons.star,
              itens: [
                "Modo claro e escuro.",
                "Google Maps com raio de atendimento.",
                "WhatsApp do prestador.",
                "Linha do tempo do serviço.",
                "Configurações de cliente e prestador.",
              ],
            ),
          ],
        );
    }
  }
}

class _ConteudoInformacao {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final List<_SecaoInformacao> secoes;

  const _ConteudoInformacao({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.secoes,
  });
}

class _SecaoInformacao {
  final String titulo;
  final IconData icon;
  final List<String> itens;

  const _SecaoInformacao({
    required this.titulo,
    required this.icon,
    required this.itens,
  });
}
