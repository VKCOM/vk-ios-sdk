VKActivity
==========

iOS 6 style sharing for Vkontakte

Смотрите пример в `TestViewController`:

    NSArray *items = @[[UIImage imageNamed:@"example.jpg"], @«Example», [NSURL URLWithString:@"https://www.youtube.com/watch?v=S59fDUZIuKY"]];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:items
                                                        applicationActivities:@[vkontakteActivity]];
    
    [self presentViewController:activityViewController animated:YES completion:nil];