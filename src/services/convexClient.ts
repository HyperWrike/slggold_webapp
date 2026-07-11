import { ConvexReactClient } from 'convex/react';

const convexUrl = process.env.EXPO_PUBLIC_CONVEX_URL || 'http://127.0.0.1:3210';

export const convexClient = new ConvexReactClient(convexUrl);
