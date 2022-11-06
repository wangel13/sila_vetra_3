import React, { useState } from 'react'
import Layout from '../components/Layout'
import useSWR from 'swr'
import { useSession } from 'next-auth/react'
import { CSVLink } from 'react-csv'

type Props = {}

export const fetcher = (url: string, ...args: any) => fetch(url, ...args).then((res) => res.json())

const formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
})

const MainPage: React.FC<Props> = (props) => {
  const [tnved, setTnved] = useState('')
  const [year, setYear] = useState('2021')
  const [size, setSize] = useState('200')
  const { data: session } = useSession()

  const { data, error, isLoading } = useSWR(`/api/results?year=${year}&tnved=${tnved}&size=${size}`, fetcher)

  if (!session) {
    return (
      <Layout>
        <main className="container mx-auto mb-10">
          <div className="shadow bg-white rounded p-4 font-bold text-gray-600">
            Вам необходимо войти в систему. Используйте демо-данные:{' '}
            <span className="text-gray-500">test@test.ru \ test123</span>
          </div>
        </main>
      </Layout>
    )
  }

  return (
    <Layout>
      <div className="page">
        <main className="container mx-auto mb-10">
          <h1 className="text-2xl font-bold mb-8">Рейтинг ТНВЭД:</h1>
          <div className="pb-8 flex gap-4 items-center">
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
            <select
              value={size}
              onChange={(e) => {
                setSize(e.target.value)
              }}
              className="py-2 px-4 bg-white w-60 border rounded"
            >
              <option>100</option>
              <option>200</option>
              <option>300</option>
              <option>400</option>
              <option>500</option>
              <option>1000</option>
            </select>
            {data && (
              <CSVLink data={data} filename={"tnved_analytics.csv"} target="_blank" separator={';'} className="px-4 py-2 bg-green-500 text-white rounded uppercase font-bold">
                Скачать таблицу
              </CSVLink>
            )}
            <a title="выводятся первые 200 ТН ВЭДов">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="w-6 h-6 text-gray-400 hover:text-gray-700"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z"
                />
              </svg>
            </a>
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
                  <div className="basis-2/12">
                    {tnved?.import_amount_usd ? formatter.format(tnved?.import_amount_usd) : 0}
                  </div>
                  <div className="basis-2/12">
                    {tnved?.export_amount_usd ? formatter.format(tnved?.export_amount_usd) : 0}
                  </div>
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
