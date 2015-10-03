---
layout: post
title: "Step by Step Configuration of XMonad"
category: Haskell
---
After months of false announcements on my behalf, I finally finished up writing 
my XMonad tutorial. As not everyone uses XMonad, let alone has ever heard of it,
I’ll start with a brief introduction.

> XMonad is a dynamically tiling X11 window manager, written and configured in 
> Haskell. It arranges windows in (usually) non-overlapping tiled patterns. Its 
> purpose? Productively manage and declutter windows without the use of the mouse.

While many tiling window managers employ a rather simple configuration, Haskell,
a λ-calculus based, functional programming language, lifts up XMonad up to one
of the most extensible and finest window managers around. Unfortunately, this
makes it difficult to configure. Haskell is known by only a limited number of
people and requires an entirely different mindset than that needed for a
declarative language.

This guide will lead you step by step through the process of setting up XMonad, 
taking my own configuration as example. A lot of the information can be found 
scattered all over [xmonad.org](http://xmonad.org). I’ve taken the liberty of
bundling the information. If you don’t want to jump through all the hoops,
simply go straight to my configuration. You can get the most up to date version
on [Github](https://github.com/Nepherte/XMonad).

Make sure to get yourself familiar with the modus operandi of XMonad before
moving on. You can do so by taking the [guided tour](http://xmonad.org/tour.html).
It’ll give you a clue about what to expect and how to get by when first
launching it. Once you’re done, get ready to configure XMonad.

# Working Directory

The main working directory is /home/\<username\>/.xmonad. This folder contains
everything XMonad needs to run on your system: the config file, the log files, 
additional modules and the compiled binary. The most important file for this 
tutorial is xmonad.hs (config file).

The configuration file is actually nothing more than a chunk of Haskell code
that contains directives for XMonad. Therefore, you will have to compile it 
into a binary every time you make a change and restart XMonad afterwards for
the change to take effect:

{% highlight haskell %}
# compile xmonad.hs to a binary
xmonad --recompile
 
# restart xmonad with new config
xmonad --restart
{% endhighlight %}

If you are having difficulties compiling xmonad.hs, you may want to look at 
xmonad.error. Though, admittedly, the error messages tend to be very vague 
and hard to comprehend. For anything more than just an obvious typo, call
the cavalry. I know I do (or not).

All code snippets posted from here on, should end up in xmonad.hs. Each snippet
only contains code for a specific section. But don’t worry, most sections have
no overlap. You should be capable of putting it all together, or, cheat and take
a peek at my xmonad.hs.

# Basic Configuration

To get things up and running, let’s start with the most basic configuration.
Nothing fancy:

{% highlight haskell %}
-- Import statements
import XMonad
 
-- Run XMonad with the defaults
main = do
    xmonad $ defaultConfig
{% endhighlight %}

It basically runs XMonad with the default configuration, called _defaultConfig_.
You don’t have to download the file. It is already included in the XMonad 
installation. However, if you do, you’ll end up with the same result.

XMonad provides out-of-the-box support for a couple of Desktop Environments.
Included are configurations for Gnome (_gnomeConfig_), KDE (_kdeConfig_) and XFCE
(_xfceConfig_). Each configuration will gracefully handle the panels and shortcut
keys inherent to the desktop environment of your choice, but the window manager
is replaced with the pure awesomeness that is XMonad. Note that you are not
required to use a desktop environment at all, regardless of the configuration
you end up using. That's how I like it.

# Default Terminal

In XMonad, the terminal is your friend. In this example, urxvt acts as the
default terminal:

{% highlight haskell %}
-- Import statements
import XMonad
 
-- Define terminal
myTerminal = "urxvt"
 
-- Run XMonad
main = do
    xmonad $ defaultConfig {
        terminal = myTerminal
    }
{% endhighlight %}

Consider _terminal_ a property that you just initialized with _myTerminal_.
Feel free to replace the value assigned to _myTerminal_ with the terminal of
your choice. The default key binding to open up a terminal is \<modMask\> +
\<shiftMask\> + Enter. On most systems this is just another way of saying Alt +
Shift + Enter. Remember this key binding, your life depends on it.

# Workspaces

While heavily underestimated in floating desktop environments, I highly
recommend everyone to use workspaces in XMonad. They provide a clean way to
semantically separate applications. To create workspaces, assign the names you 
want to use to _workspaces_.

{% highlight haskell %}
-- Import statements
import XMonad
 
-- Define the names of all workspaces
myWorkspaces = ["main","web","chat","media","browse","dev","mail"]
 
-- Run XMonad
main = do
    xmonad $ defaultConfig {
        workspaces = myWorkspaces
    }
{% endhighlight %}

The default keybinding to switch to a workspace is \<modMask\> + \[1,2,...,n\].
More on that later in [Key Bindings](#key-bindings).

# Applications

Workspaces are a great way to organize applications. Let us assume you want to
keep web browsers and chat applications separate. To achieve this, you assign
each group of applications to a dedicated workspace by specifying a _manageHook_.

{% highlight haskell %}
-- Import statements
import XMonad
import Control.Monad
import qualified XMonad.StackSet as W
 
-- Define the names of all workspaces
myWorkspaces = ["main","web","chat","media","browse","dev","mail"]
 
-- Define the workspace an application has to go to
myManageHook = composeAll . concat $
    [
          -- Applications that go to web
        [ className =? b --> viewShift "web"      | b <- myClassWebShifts  ]
         -- Applications that go to chat
      , [ resource  =? c --> doF (W.shift "chat") | c <- myClassChatShifts ]
    ]
    where
        viewShift = doF . liftM2 (.) W.greedyView W.shift
        myClassWebShifts  = ["Firefox"]
        myClassChatShifts = ["Pidgin" ]
 
-- Run XMonad
main = do
    xmonad $ defaultConfig {
        workspaces = myWorkspaces
      , manageHook = myManageHook
    }
{% endhighlight %}

Notice the difference in the way web applications and chat applications are
shifted to their workspace. Both applications will end up in the workspace
they’re assigned to, but chat applications do so in the background. The
current workspace remains active. On the other side of the spectrum, when you
launch an application, one usually expects to see that particular window.
That is exactly what _viewShift_ does. It shifts focus to the workspace
containing the application.

To identify an application, you can either use class names (_className_),
resources (_resource_) and/or title names (_title_). To get the properties of an
application, simply run xprop in a console and click on the window to identify.
Here’s the partial output for Pidgin:

{% highlight bash %}
$ xprop
WM_WINDOW_ROLE(STRING) = "buddy_list"
WM_CLASS(STRING) = "Pidgin", "Pidgin"
WM_NAME(STRING) = "Buddy List"
{% endhighlight %}

The class name of an application corresponds to the first value of WM_CLASS 
(“Pidgin”). The resource corresponds to the second value of WM_CLASS 
(also “Pidgin”). The title corresponds to WM_NAME (“Buddy List”).

# Tiling Windows

This is the mother of all features. Tiling is a way of organizing application
windows on your screen. In XMonad, layouts express how to position each window. 
Let’s take a closer look at how layouts actually work. It is  after all a tiling
window manager, right?

Each layout consists of a master pane and one or more slave panes. When you 
launch a new application, it opens up in the pane that contains the focused 
window. XMonad then reorganizes and resizes all windows in the workspace 
according to the active layout. Think of it as a set of rules that tell XMonad 
where to put each window. Now surely you can come up with a few ways to organize
windows. Choosing the layouts that fit your needs, is vital for the overall
experience of a tiling window manager. So choose carefully!

To help you choose, I grouped together 4 popular layouts that make a lot of 
sense:

- _Tall_ is a layout with one master pane and one slave pane. The master pane
occupies the left part of the screen, the slave pane occupies the remainder. 
Inside a pane, windows are organized as rows. The width ratio of both panes is 
configurable, as is the maximum number of windows in the master pane. This is, 
without a doubt, the most popular layout. Often used as default.

- _Full_ is a layout where each application occupies the whole screen. Only
displays the focused window, other windows are placed underneath. Perfectly 
suited for workspaces with very few windows. A popular choice to maximize 
windows.

- _SimpleFloat_ is a (pseudo-)layout that floats all windows. Each window gets a
small title bar. _SimplestFloat_ is identical, but without the title bar. Your
one and only choice for a dedicated floating workspace. More on the subject in
[Floating windows](#floating-windows).

- _Mirror Tall_ is similar to _Tall_, but 90 degrees rotated. The master pane
occupies the top part of the screen, the slave pane occupies the remainder. 
Inside a pane, windows are organized as columns. _Mirror_ is actually a modifier
that can be applied to layouts.

Even though only one layout can be active at a time, you are not limited to
just one layout per workspace. You can define a whole set of layouts and switch
between them whenever it pleases you. The default key binding to switch between
layouts is \<modMask\> + Space.

{% highlight haskell %}
import XMonad
import XMonad.Layout.SimpleFloat
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
 
-- Define default layouts used on most workspaces
defaultLayouts = tiled ||| Mirror tiled ||| simpleFloat ||| Full
    where
        -- default tiling algorithm partitions the screen into two panes
        tiled   = Tall nmaster delta ratio
        -- The default number of windows in the master pane
        nmaster = 1
        -- Default proportion of screen occupied by master pane
        ratio   = 1/2
        -- Percent of screen to increment by when resizing panes
        delta   = 3/100
 
-- Define layout for specific workspaces
mediaLayout = noBorders $ Full
 
-- Put all layouts together
myLayouts = onWorkspace "media" mediaLayout $ defaultLayouts
 
-- Run XMonad
main = do
    xmonad $ defaultConfig {
        layoutHook = myLayouts
   }
{% endhighlight %}

In the example above, I’ve used the layouts discussed earlier and assigned them
to _layoutHook_. The layouts apply to all but one workspace (media). With the
directive _onWorkspace_, you can set up layouts per workspace. The example
assigns a single layout to media. All other workspaces use _defaultLayouts_. The
_noBorders_ modifier removes the borders surrounding a window.

# Floating Windows

By default, XMonad tiles all windows. But once in a while you don’t want to tile 
an application at all. Classic examples are MPlayer and GIMP. Let’s take GIMP, 
for example. It has many separate tool box windows, and every single one of
them gets tiled. Things get messy!

Before you choose to float an application, ask yourself "Is this
necessary?" You really don’t want too many floating windows. Why would you be
using XMonad otherwise? Take MPlayer for instance. I watch movies in full screen
mode. Simply put it on a separate workspace using the _Full_ layout. To avoid
scaling issues, I set MPlayer’s aspect ratio to 16:10, which matches the ratio of my screen.

Okay, I really do want to float an application. How do i do that? Just create an
entry for it in the manageHook:

{% highlight haskell %}
-- Import statements
import XMonad
 
-- Define the workspace an application has to go to
myManageHook = composeAll . concat $
    [
        -- Applications that float
       [ className =? i --> doFloat | i <- myClassFloats ]
    ]
    where
        myClassFloats = ["mplayer"]
 
-- Run XMonad
main = do
    xmonad $ defaultConfig {
        manageHook = myManageHook
   }
{% endhighlight %}

# Key Bindings

Another killer feature of XMonad are key bindings. Control your desktop with 
nothing but a keyboard. A mouse is so overrated, is it not? Not only is it very 
useful to know the most important key bindings in XMonad, it’s also a good idea 
to create new ones to facilitate your work in XMonad. Once you get the hang of 
it, it will speed things up significantly. And that’s what this is all about.

XMonad lets you add, remove and redefine key bindings. To complicate things, it 
allows you to do this in more than one way. I will demonstrate what I believe to 
be the easiest way. Feel free to investigate the other approach.

There are a few things you should know about key bindings in XMonad. To start 
with, a key binding always involves zero or more key masks, a key symbol and the
action to perform. Each symbol is prefixed with xK. If you wish to set up a key
binding using the key p, you should actually use xK_p. Needless to say, you can
combine several modifiers. The action itself can be anything you want it to be.

{% highlight haskell %}
-- Import statements
import XMonad
import XMonad.Util.Run
import XMonad.Actions.CycleWS
import qualified Data.Map as M
 
-- Define keys to add
keysToAdd x =
    [
        -- Close window
           ((modMask x, xK_c), kill)
        -- Shift to previous workspace
        ,  (((modMask x .|. controlMask), xK_Left), prevWS)
        -- Shift to next workspace
        ,  (((modMask x .|. controlMask), xK_Right), nextWS)
        -- Shift window to previous workspace
        ,  (((modMask x .|. shiftMask), xK_Left), shiftToPrev)
        -- Shift window to next workspace
        ,  (((modMask x .|. shiftMask), xK_Right), shiftToNext)
        -- Play / pause song in mpd
        , ((modMask x, xK_p), spawn "ncmpcpp toggle")
        -- Play previous song in mpd
        , ((modMask x, xK_Left), spawn "ncmpcpp prev")
        -- Play next song in mpd
        , ((modMask x, xK_Right), spawn "ncmpcpp next")
    ]
 
-- Define keys to remove
keysToRemove x =
    [
        -- Unused gmrun binding
          (modMask x .|. shiftMask, xK_p)
        -- Unused close window binding
        , (modMask x .|. shiftMask, xK_c)
    ]
 
-- Delete the keys combinations we want to remove.
strippedKeys x = foldr M.delete (keys defaultConfig x) (keysToRemove x)
 
-- Compose all my new key combinations.
myKeys x = M.union (strippedKeys x) (M.fromList (keysToAdd x))
 
-- Run XMonad
main = do
    xmonad $ defaultConfig {
        keys = myKeys
    }
{% endhighlight %}

# Status Bar

A status bar is an invaluable tool to display information about the state of
XMonad: What workspace am I on? What layout is in use? What’s the title of the
focused window? What workspaces contain windows? All this and more is provided
by logHook. An actual status bar is unfortunately not included. For that, we
rely on a 3rd-party application. XMonad integrates nicely with dzen2 (and xmobar).

[Patrick Brisbin](https://pbrisbin.com) wrote a little Haskell library for
dzen2. It makes it very easy to create a dzen2 status bar. Download it from
[Github](https://github.com/pbrisbin/xmonad-config/blob/92b2653aabd4c3ca1854473e3679a2f11e278550/lib/Dzen.hs)
and put it inside  /home/\<user\>/.xmonad/lib/. Do not forget to install dzen2.
Otherwise it won’t work.

To get a status bar up and running, you have to: 1) create a status bar 2)
decide on the information to display and 3) specify how to format it. The
example below is pretty straight forward. Don’t forget to adjust the size of the
dzen2 bar to your needs. You may also want to use a another font and different
colors.

{% highlight haskell %}
-- Import statements
import Dzen
import XMonad
import XMonad.Hooks.DynamicLog hiding (dzen)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Run
 
-- Workspace dzen bar
myStatusBar = DzenConf {
      xPosition  = Just 0
    , yPosition  = Just 0
    , width      = Just 1920
    , height     = Just 24
    , alignment  = Just LeftAlign
    , font       = Just "Bitstream Sans Vera:pixelsize=11"
    , fgColor    = Just "#ffffff"
    , bgColor    = Just "#000000"
    , exec       = []
    , addargs    = []
}
 
-- Log hook that prints out everything to a dzen handler
myLogHook h = dynamicLogWithPP $ myPrettyPrinter h
 
-- Pretty printer for dzen workspace bar
myPrettyPrinter h = dzenPP {
      ppOutput          = hPutStrLn h
    , ppCurrent         = dzenColor "#000000" "#e5e5e5"
    , ppHidden          = dzenColor "#e5e5e5" "#000000"
    , ppHiddenNoWindows = dzenColor "#444444" "#000000"
    , ppUrgent          = dzenColor "#ff0000" "#000000". dzenStrip
    , ppWsSep           = " "
    , ppSep             = " | "
}
 
-- Run XMonad
main = do
    workspaceBar <- spawnDzen myStatusBar
    xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig {
        logHook             = myLogHook workspaceBar
      , manageHook          = manageDocks
}
{% endhighlight %}

The example tracks urgent windows using _withUrgencyHook_. Workspaces containing
windows that require your attention will be highlighted. Think of a chat
application for instance. If someone sends you a message while you’re on a
different workspace, the label of that workspace gets the color that is assigned
to _ppUrgent_.

Layouts by default do not detect the presence of status bars. As a result,
windows will cover them. In order for status bars not to overlap with windows,
use _manageDocks_. It will make layouts aware of the status bar’s position and
dimensions.

# Final Notes

All things come to an end. And while there is still much to be told about
XMonad, you now have a fairly good idea of the possibilities. I hope this
guide has been very helpful in setting up and personalizing your setup. If you
feel that something important has been left out or if you have any question, do
not hesitate to contact me.