

Loading Dependency Trees in Bevy
================================

The Bevy Engine has a robust Asset handling architecture whose primary moving parts are:
1. The AssetServer which handles asyncronously loading and unloading assets.
2. Asset Handles which are basically references to an asset.
3. Assets resources which are used to get concrete data from an asset handle.

When I started with Bevy ~0.3 I wanted to load assets which referenced other assets.
For example, the struct I wanted to work with looked like this:

.. code:: rust

    struct MyAsset {
        audio: Handle<AudioSource>,
        model: Handle<Gltf>,
        // etc...
    }

With an asset file like this:

.. code:: json

    // path/to/some.asset
    MyAsset(
        audio: "path/to/audio.ogg",
        model: "path/to/models.gltf",
        // etc...
    )

This should read ``some.asset`` and implicitly convert ``"path/to/audio.ogg"`` into a ``Handle<AudioSource`` pointing at the Audio asset I'm trying to use.

But most out-of-the-box asset deserializers like the bevy-ron-assets plugin only have examples for loading simple types like String and Float and Vec, but how would you directly transform a struct mapping members to strings into a struct mapping members to Asset Handles?

Well initially my solution was to use Bevy Resources.
These are not assets, which are asyncronously loaded and updated based on a file on disk, but instead an object entirely in memory.
The downside with using Resources is I had to jump through some hoops:

1. Load my ``member -> string`` asset.
2. Watch for Asset events and when the asset was updated, update my resource.

This sounds trivial, but one catch with Bevy assets is that when a Handle is dropped, the asset is unloaded from the Asset Server, so I couldn't just over-write my entire Resource representation of an Asset, because that would drop any currently heald handles.
Instead I had to do some simple diffing and update my Resource in-place to only update Handles which had changed.
This isn't a ton of overhead but it's needless complexity.

Earlier this week I went about solving this problem.
I felt it had to be _possible_ to convert an input file of keys and values into a struct of members and Handles.

After banging my head against the problem I asked in the discord what the problem was and if there was a solution and it was starting my right in the face: `with_dependencies`.
This method allowed us to add a dependency to Bevy and while doing so queue up additional dependencies.
Now my assets dependency tree was totally possible and I could cut out a _ton_ of boilerplate code used to transform Assets into Resources.
All I needed was to store my handles in memory somewhere, probably in a set, and Bevy would take care of the rest.
