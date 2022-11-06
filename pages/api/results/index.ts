import type { NextApiRequest, NextApiResponse } from 'next'
import prisma from '../../../lib/prisma'
import { getSession } from 'next-auth/react'

// GET /api/adjustment_scores
export default async function handle(req: NextApiRequest, res: NextApiResponse) {
  const { year, tnved } = req.query

  const session = await getSession({ req })
  if (session) {
    const result = await prisma.final_rating.findMany({
      take: 200,
      // skip: 1, // Skip the cursor
      // @ts-ignore
      where: {
        year: Number(year),
        ...(tnved && { tnved: { startsWith: tnved } }),
      },
      orderBy: {
        score: 'desc',
      },
    })
    res.json(result)
  } else {
    res.status(401).send({ message: 'Unauthorized' })
  }
}
