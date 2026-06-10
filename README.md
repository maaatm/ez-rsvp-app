# e-z.rsvp iOS app
Say yes now. Find out later. e-z.rsvp matches you and your friends with surprise adventures without decision fatigue. It's our job to find the events. All you have to do is show up.

## Inspiration
The idea for e-z.rsvp was born from a problem our friend group experienced constantly. We wanted to spend more time together, but making plans often felt harder than it should. We'd talk about hanging out for days, throw around ideas in a group chat, and somehow never decide on anything. What started as excitement often turned into indecision, and the plans simply never happened. 

We realized that one of the biggest barriers to spending time together wasn't a lack of interest, it was the fact that we didn’t know what to do. e-z.rsvp removes that friction by matching friends with surprise experiences and letting them focus on what matters most: showing up. By turning planning into an adventure, we help people create meaningful memories with the people they care about.

## What it does
When browsing the mobile or web application, users are able to browse local events based on their interests, availability, budget, and preferred travel radius. They are unable to know  where exactly the event is or what it is, however we do allow the option to view the broad category an event is in in order to drive up satisfaction rates. 

Once a user chooses which ticket(s) they want, they are free to purchase tickets and essentially RSVP to a mystery experience tailored to their preferences. As the user keeps using the app, going to events, and rating them, the app can also learn their preferences to recommend better events in the future.

The app includes a feature to create groups so people can coordinate tickets with their friends and track whose going in realtime, however it is not necessary to be a part of a group to go to an event. Part of the fun is meeting new people!

Leading up to an event, users will receive clues about the event meant to build anticipation while keeping the destination secret. A live countdown tracks the time until reveal, and on event day, the app reveals the experience, location, event details, and directions. Users can also share their revealed adventure with friends through automatically generated social media cards, turning every event into a memorable and shareable experience.

We understand that safety is a major concern for an application like this. As such, all venues would be public and vetted by the team at e-z rsvp. We would also allow an emergency contact to be stored in the settings page who will automatically get a message with the event details. 

## How we built it
The e-z.rsvp iOS was built entirely with Swift. The web application was built with Next.js, TypeScript, React, and Tailwind CSS. We chose to use this tech stack as we were most familiar with these technologies. 

We then Supabase for both applications in order to store user data and Vercel to deploy our website. We chose Vercel due to extreme familiarity, and Supabase because of its rising usage and mentions on the technology side of social media, causing us to want to learn how to use it. 

We used the Google Cloud Console to allow users to sign in via Google. This was used to set up the authentication flow.

Finally, to authorize payments we used Stripe. Our demo uses the developer sandbox to ensure no payments are accidentally processed.

## Challenges we ran into
A major challenge we ran into was the scope of our idea. Our goal for this project was to end with two fully functional mobile and web applications. As a team of two, this left us each choosing our preferred application type and working on it ourselves from the ground up. The features we wanted to add and the amount of new material we needed to learn made this a very challenging task to accomplish.

Another challenge we had was implementing our “Find events” page, as this page had a ton of moving parts. We had to deal with filter systems, address searching, displaying tickets while hiding key information, and authorizing payments through Stripe. All of this was completely new and was very daunting to create. 

A third challenge was implementing the overlays in the web application. There were many different overlays and figuring out how to do it, having a consistent design, and handling when there were 2 overlays at once were all difficult issues to solve.

Finally, a big hurdle during the app development was the physical limitations of an iPhone. Testing the app in the Xcode simulator always worked just fine, but once we started testing on our own phones we were running into issues with energy consumption, with the GPU usage spiking at seemingly random times. We had to really retrace our steps in order to address this issue, drawing back on visual effects and loops.

## Accomplishments that we're proud of
Our first big accomplishment was our idea. We spent hours looking through the database of domain names provided by name.com and sat and brainstormed. We wanted to create an idea that gave a unique spin to a domain rather than settling with something obvious. We used artificial intelligence at this stage to generate ideas for the project so that we knew what ideas to avoid as they were too obvious to choose. Finally, after coming up with a lot of bad ideas that didn’t stick, we came up with our spin on e-z.rsvp, successfully beating our first major hurdle.

Another of our biggest accomplishments was the design. We believe that the best way to bring in customers and have people truly trust our product starts with having a cohesive design they like. This led us to spend a lot of time figuring out how we wanted the mobile and web applications to look and how the features we wanted to implement would fit in to it. We ended up with a very sleek, modern design that we thought looked beautiful and that we felt would appeal to the average Gen-Z consumer. Everything was thought through, from overarching page designs to small things like what fonts to use, in order to provide users a seamless, interactive, and beautiful experience.

## What we learned
There was a lot of new technology we learned through the process. Prior to creating this application, we have never used Supabase, have not written this robust of a website in React and TypeScript, and have barely touched Swift. This meant that we had a lot to learn in order to tackle this project. Through the time period we had to develop our product we were able to learn a lot of the fundamentals of this technology. A major contributor to that was our usage of AI. We used AI in this project to develop roadmaps for us, find useful resources for us to learn these technologies, and help debug, write, and clean code for us when we got stuck.

## What's next for e-z.rsvp
The next phase for e-z.rsvp would be community building and monetization. Our primary monetization strategy is to partner with local businesses and venues to increase attendance at events during off peak hours or seasons. They would be able to sponsor platform exclusive discounts in exchange for featured placement in the app. In order to reach our target audience of Gen-Z and Millenials, we would do the bulk of our marketing on social media platforms such as TikTok and Instagram by reaching out to small content creators and running ads. As our app attracts more users, the sharable experiences and social features form a natural viral growth loop. In the long-term, we think e-z.rsvp has the potential to be a leading social platform while creating a marketplace for businesses and event planners.
