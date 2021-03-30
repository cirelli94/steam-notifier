# steam-notifier
This is just a simple script that use [steamctl](https://github.com/ValvePython/steamctl) to check if there is a new update for your games!
To setup `steam-notifier` you have to follow some simple steps:

```
$ mkdir $HOME/.config/steam-notifier
$ touch $HOME/.config/steam-notifier/1234567 # touch every game you want to check
$ cp ./steam-notifier.sh $HOME/bin/steam-notifier
$ sudo cp ./steam-notifier.service /etc/systemd/system/steam-notifier.service
$ steamctl apps list # insert credential first time!
$ sudo systemctl enable --now steam-notifier.service
```

I tried this on X11 and Wayland.
