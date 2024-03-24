const Bar = (monitor: number) => Widget.Window({
    name: `bar-${monitor}`,
    child: Widget.Label('hello'),
});

App.config({
    windows: [Bar(0), Bar(1)]
});
