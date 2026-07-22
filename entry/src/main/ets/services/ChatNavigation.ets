import router from '@ohos.router';

export class ChatNavigation {
  static chatHome(): string {
    return 'pages/ChatMain';
  }

  static returnToChat(): void {
    router.pushUrl({ url: ChatNavigation.chatHome() });
  }
}
