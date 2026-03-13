export interface User {
  id: string;
  email: string;
  createdAt: string;
  updatedAt: string;
}

export interface MarketplaceCategory {
  id: number;
  name: string;
}

export interface MarketplaceFeed {
  id: string;
  categoryId: number;
  title: string;
  url: string;
  description?: string;
  iconUrl?: string;
}

export interface SyncState {
  articleGuid: string;
  readAt?: string;
  starredAt?: string;
}
