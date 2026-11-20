#include <emacs-module.h>

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#include <stdint.h>

int plugin_is_GPL_compatible;

static emacs_value
style_posframes(emacs_env *env, ptrdiff_t nargs, emacs_value *args, void *data)
{
  (void)data;
  intmax_t radius = nargs > 0 ? env->extract_integer(env, args[0]) : 12;
  intmax_t red = nargs > 1 ? env->extract_integer(env, args[1]) : 186;
  intmax_t green = nargs > 2 ? env->extract_integer(env, args[2]) : 187;
  intmax_t blue = nargs > 3 ? env->extract_integer(env, args[3]) : 241;
  NSInteger styled = 0;

  @autoreleasepool {
    NSColor *borderColor = [NSColor colorWithSRGBRed:(CGFloat)red / 255.0
                                               green:(CGFloat)green / 255.0
                                                blue:(CGFloat)blue / 255.0
                                               alpha:1.0];
    for (NSWindow *window in [NSApp windows]) {
      if ([window parentWindow] == nil
          || ![window isVisible]
          || ![[window title] isEqualToString:@"ivy-posframe"])
        continue;

      [window setHasShadow:NO];
      [window setOpaque:NO];
      [window setBackgroundColor:[NSColor clearColor]];

      NSView *contentView = [window contentView];
      [contentView setWantsLayer:YES];
      CALayer *layer = [contentView layer];
      [layer setMasksToBounds:YES];
      [layer setCornerRadius:(CGFloat)radius];
      [layer setBorderWidth:1.0];
      [layer setBorderColor:[borderColor CGColor]];
      if (@available(macOS 10.15, *))
        [layer setCornerCurve:kCACornerCurveContinuous];
      [contentView setNeedsDisplay:YES];
      ++styled;
    }
  }

  return env->make_integer(env, styled);
}

static void
bind_function(emacs_env *env, const char *name, emacs_value function)
{
  emacs_value arguments[] = {env->intern(env, name), function};
  env->funcall(env, env->intern(env, "defalias"), 2, arguments);
}

int
emacs_module_init(struct emacs_runtime *runtime)
{
  emacs_env *env = runtime->get_environment(runtime);
  emacs_value function = env->make_function(
      env, 0, 4, style_posframes,
      "Round visible Ivy Posframe child windows and remove their shadows.\n\n"
      "Optional arguments are RADIUS, RED, GREEN, and BLUE.",
      NULL);
  bind_function(env, "my/ivy-posframe--style-native-frames", function);
  return 0;
}
