VKActivity
==========

iOS 6 style sharing for Vkontakte через стандартное API.

Смотрите пример в `TestViewController`:

    NSArray *items = @[[UIImage imageNamed:@"example.jpg"], @"Противостояние Запада и России" , [NSURL URLWithString:@"http://vk.com/videos-29622095"]];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:items
                                                        applicationActivities:@[vkontakteActivity]];
    [activityViewController setValue:@"Мировое закулисье" forKey:@"subject"];
    [activityViewController setCompletionHandler:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
