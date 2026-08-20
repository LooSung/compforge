import { TodosScreen } from '../features/todos/TodosScreen';
import { getRequestId } from '../server/requestId';

type HomePageProps = {
  searchParams: Promise<{ filter?: string | string[] }>;
};

function firstParam(value: string | string[] | undefined): string | undefined {
  if (Array.isArray(value)) {
    return value[0];
  }
  return value;
}

export default async function HomePage({ searchParams }: HomePageProps) {
  // Server-only values stay here. Serializable URL snapshots may cross into
  // the client island so SSR matches the bookmark (getServerSnapshot).
  void getRequestId();
  const params = await searchParams;
  return <TodosScreen initialFilter={firstParam(params.filter)} />;
}
