import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_controller.dart';
import '../widgets/ui.dart';
import 'app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool visible = false, register = false, busy = false;
  String? message;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void enter() => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()), (_) => false);
  Future<void> submit() async {
    final cloud = context.read<AppController>().cloud;
    if (cloud == null) {
      setState(() => message =
          'O acesso com conta ainda não está disponível. Use “Explorar protótipo” para conhecer o aplicativo.');
      return;
    }
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (register) {
        await cloud.register(email.text.trim(), password.text);
      } else {
        await cloud.login(email.text.trim(), password.text);
      }
      if (mounted) enter();
    } catch (_) {
      if (mounted)
        setState(() => message =
            'Não foi possível acessar a conta. Confira os dados e tente novamente.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(''),
            leading: BackButton(
                onPressed: busy ? null : () => Navigator.pop(context))),
        backgroundColor: Colors.white,
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 12, 26, 28),
                    child: Form(
                        key: form,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                  child: Image.asset('assets/images/marca.png',
                                      width: 108, height: 108)),
                              const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(
                                            text: 'Primeiro ',
                                            style: TextStyle(color: ink)),
                                        TextSpan(
                                            text: 'Passo',
                                            style: TextStyle(color: purple))
                                      ]),
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1))),
                              const Text(
                                  'Do primeiro passo ao primeiro emprego.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted, fontSize: 11)),
                              const SizedBox(height: 30),
                              Text(register ? 'Crie sua conta' : 'Bem-vindo!',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w800,
                                      color: ink)),
                              const SizedBox(height: 5),
                              Text(
                                  register
                                      ? 'Seu próximo passo começa aqui.'
                                      : 'Faça seu login para continuar.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: muted)),
                              const SizedBox(height: 22),
                              TextFormField(
                                  controller: email,
                                  enabled: !busy,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: const InputDecoration(
                                      labelText: 'E-mail',
                                      prefixIcon: Icon(Icons.person_outline)),
                                  validator: (v) => v != null &&
                                          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                              .hasMatch(v.trim())
                                      ? null
                                      : 'Informe um e-mail válido.'),
                              const SizedBox(height: 14),
                              TextFormField(
                                  controller: password,
                                  enabled: !busy,
                                  obscureText: !visible,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                      labelText: 'Senha',
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                          tooltip: visible
                                              ? 'Ocultar senha'
                                              : 'Mostrar senha',
                                          onPressed: () => setState(
                                              () => visible = !visible),
                                          icon: Icon(visible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined))),
                                  validator: (v) => v != null && v.length >= 6
                                      ? null
                                      : 'Use pelo menos 6 caracteres.'),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                      onPressed: busy
                                          ? null
                                          : () => setState(() => message =
                                              'A recuperação de senha estará disponível quando o acesso com conta for ativado.'),
                                      child:
                                          const Text('Esqueci minha senha'))),
                              if (message != null)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Text(message!,
                                        style: const TextStyle(
                                            color: muted, fontSize: 13))),
                              FilledButton(
                                  onPressed: busy ? null : submit,
                                  child: Text(busy
                                      ? 'Aguarde…'
                                      : register
                                          ? 'Criar conta'
                                          : 'Entrar')),
                              const SizedBox(height: 16),
                              const Row(children: [
                                Expanded(child: Divider()),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('Ou continue com',
                                        style: TextStyle(
                                            color: muted, fontSize: 12))),
                                Expanded(child: Divider())
                              ]),
                              const SizedBox(height: 12),
                              const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _Social('G', 'Google'),
                                    SizedBox(width: 12),
                                    _Social('●', 'Apple'),
                                    SizedBox(width: 12),
                                    _Social('in', 'LinkedIn')
                                  ]),
                              const SizedBox(height: 10),
                              const Text('Acesso social em breve',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted, fontSize: 11)),
                              TextButton(
                                  onPressed: busy
                                      ? null
                                      : () => setState(() {
                                            register = !register;
                                            message = null;
                                          }),
                                  child: Text(register
                                      ? 'Já tenho conta'
                                      : 'Ainda não tem uma conta? Criar conta')),
                              const Divider(),
                              TextButton(
                                  onPressed: busy ? null : enter,
                                  child: const Text('Explorar protótipo')),
                              const Text(
                                  'Experimente sem conta. As informações ficam neste dispositivo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted, fontSize: 11)),
                            ]))))),
      );
}

class _Social extends StatelessWidget {
  final String text, name;
  const _Social(this.text, this.name);
  @override
  Widget build(BuildContext context) => Tooltip(
      message: '$name — em breve',
      child: OutlinedButton(
          onPressed: null,
          child: Text(text,
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))));
}
