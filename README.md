## Libraries used
ddavness/curve@0.1.0
I co-authored this with ddavness. I wrote the initial version, after which we had a long conversation on the API design requirements, and we rewrote it collaboratively. He wrote the code on his computer while I gave feedback on the functions being written, and provided the bezier implementations using Bernstein polynomials, along with the implementation for splines.

## Approach
Initially, I opted for a server-sided physics simulation, where the bags are spawned in on the server and simply ride the Velocity of the anchored track parts. However, trustemix showed some concern with what would happen if the conveyor belt got a lot longer, which would mean that the network usage would increase for replicating the parts's positions.

For the sake of experimentation, and showcasing a more complex approach, I opted to animate the bags entirely on the client using the same bezier curves used to create the track in the first place. The animation speed is normalized using the derivative of the bezier curve, and the framerate. So clients will stay in sync regardless of frame rate.

Normally bezier animations are faster around corners, which is why they have to be normalized to the magnitude of the first derivative.

The parts don't exist on the server, and it currently doesn't keep track of valid bag IDs. Obviously, the server being able to print the IDs of non-existent bags is not a security issue, however, in case it matters, it would be trivial to keep a table of valid IDs and use it to sanitize the remote event.

The remote event for changing the spawn rate however, is sanitized. The input is clamped, and only the designated player is allowed to change it.


## Why beziers, and not something simpler?
I wanted to show case something more complex and procedurally generated.

## What would I change?

I left it as is for time, but I would split the client script into a few module scripts to make things easier to find. Additionally, I would replace many of the magic numbers in the animation system to entries on a settings table.

If the 300 part count of the track is a concern, it can be replaced with a set of meshes, however that would take much longer, and performance is good enough for such a short track.

## Performance?
Performance is very good, network usage is basically indistinguishable from an empty baseplate, and framerate is constant.