import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/debug/debug_page.dart';
import 'package:localsend_app/widget/local_send_logo.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          const SizedBox(height: 20),
          const LocalSendLogo(withText: true),
          Text(
            '© ${DateTime.now().year} XingSend',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(t.aboutPage.description.join('\n\n')),
          const SizedBox(height: 20),
          Text(
            '基于 LocalSend (Apache-2.0)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'XingSend 是基于开源项目 LocalSend（作者 Tien Do Nam 及其社区贡献者）的私人定制版，感谢他们的出色工作。',
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://github.com/Jason201012/XingSend'), mode: LaunchMode.externalApplication);
                },
                child: const Text('Source Code (GitHub)'),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://github.com/localsend/localsend'), mode: LaunchMode.externalApplication);
                },
                child: const Text('LocalSend (Upstream)'),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://localsend.org'));
                },
                child: const Text('localsend.org'),
              ),
              TextButton(
                onPressed: () async {
                  await launchUrl(Uri.parse('https://www.apache.org/licenses/LICENSE-2.0'));
                },
                child: const Text('Apache License 2.0'),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const LicensePage());
                },
                child: const Text('License Notices'),
              ),
              TextButton(
                onPressed: () async {
                  await context.push(() => const DebugPage());
                },
                child: const Text('Debugging'),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
