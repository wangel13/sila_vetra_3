import React, { useState } from 'react'
import Layout from '../components/Layout'
import useSWR from 'swr'
import { useSession } from 'next-auth/react'

type Props = {
}

export const fetcher = (url: string, ...args: any) => fetch(url, ...args).then((res) => res.json())

const formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
});

const MainPage: React.FC<Props> = (props) => {
  const [tnved, setTnved] = useState('')
  const [year, setYear] = useState('2021')
  const { data: session } = useSession()

  const { data, error, isLoading } = useSWR(`/api/results?year=${year}&tnved=${tnved}`, fetcher)

  if (!session) {
    return (
      <Layout>
        <main className="container mx-auto mb-10">
          <div className="shadow bg-white rounded p-4 flex gap-8 flex-nowrap font-bold text-gray-600">
            Вам необходимо войти в систему.
          </div>
        </main>
      </Layout>
    )
  }

  return (
    <Layout>
      <div className="page">
        <main className="container mx-auto mb-10">
          <h1 className="text-2xl font-bold mb-8">Рейтинг ТНВЭД для замещения:</h1>
          <div className="pb-8 flex gap-4">
            <input
              value={tnved}
              className="py-2 px-4 border rounded"
              placeholder="Введите ТН ВЭД"
              onChange={(e) => {
                setTnved(e.target.value)
              }}
            />
            <select
              value={year}
              onChange={(e) => {
                setYear(e.target.value)
              }}
              className="py-2 px-4 bg-white w-60 border rounded"
            >
              <option>2019</option>
              <option>2020</option>
              <option>2021</option>
              <option>2022</option>
            </select>
          </div>
          <div className="flex gap-4 flex-col">
            <div className="shadow bg-white rounded p-4 flex gap-8 flex-nowrap font-bold text-gray-600">
              <div className="basis-1/12">ТН ВЭД</div>
              <div className="basis-6/12">Название</div>
              <div className="basis-2/12">Импорт</div>
              <div className="basis-2/12">Экспорт</div>
              <div className="basis-1/12">Рейтинг</div>
            </div>
            {data &&
              data.map((tnved) => (
                <div key={tnved?.tnved} className="shadow bg-white rounded p-4 flex gap-8 flex-nowrap">
                  <div className="basis-1/12">{tnved?.tnved}</div>
                  <div className="basis-6/12">{tnved?.tnved_title}</div>
                  <div className="basis-2/12">{tnved?.import_amount_usd ? formatter.format(tnved?.import_amount_usd) : 0}</div>
                  <div className="basis-2/12">{tnved?.export_amount_usd ? formatter.format(tnved?.export_amount_usd) : 0}</div>
                  <div className="basis-1/12">{tnved?.score}</div>
                </div>
              ))}
          </div>
          {error && 'Ошибка БД'}
        </main>
      </div>
    </Layout>
  )
}

export default MainPage
