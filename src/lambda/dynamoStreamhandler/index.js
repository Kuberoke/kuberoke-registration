import { default as sgMail } from '@sendgrid/mail'
import * as qr from 'qrcode'
import * as crypto from 'crypto'

sgMail.setApiKey(process.env.SENDGRID_API_KEY)

const sendConfirmationEmail = async (data) => {
  const msg = {
    to: data.email,
    from: 'registration@mail.kuberoke.love',
    subject: 'Your registration for Kuberoke',
    text: 'You have successfully registered for Kuberoke!',
    html: '<p>You have successfully registered for Kuberoke!</p>'
  }

  try {
    await sgMail.send(msg)
    return
  } catch (error) {
    console.error(error)

    if (error.response) {
      console.error(error.response.body)
    }
  }
}

const sendQr = async (data) => {
  qr.toDataURL(JSON.stringify(data), async (err, url) => {
    const msg = {
      to: data.email,
      from: 'registration@mail.kuberoke.love',
      subject: 'QR code for kuberoke',
      text: 'Here’s an attachment for you!',
      html: '<p>Here’s an attachment for you!</p>',
      attachments: [
        {
          content: url.split(',')[1],
          filename: 'qrcode.png',
          type: 'image/png',
          disposition: 'attachment',
          content_id: 'qrcode'
        },
      ],
    }

    try {
      await sgMail.send(msg)
      return
    } catch (error) {
      console.error(error)

      if (error.response) {
        console.error(error.response.body)
      }
    }
  })
}

export const handler = async (event, context) => {
  await Promise.all(event['Records'].map(record => {
    const newEmail = record.dynamodb?.NewImage?.email?.S
    const oldEmail = record.dynamodb?.OldImage?.email?.S

    const qrsentat = record.dynamodb?.NewImage?.qrsentat?.N
    const qrsentatBefore = record.dynamodb?.OldImage?.qrsentat?.N

    const data = {
      email: newEmail,
      name: record.dynamodb?.NewImage?.name?.S,
      code: record.dynamodb?.NewImage?.code?.S || '',
      timestamp: record.dynamodb?.NewImage?.datetime?.N,
      qrsentat,
      minutestoarrive: record.dynamodb?.NewImage?.minutestoarrive?.N || 20
    }

    if (qrsentat !== undefined && qrsentatBefore === undefined) {
      // TODO use key pair from secrets manager or via env var
      // const { publicKey, privateKey } = crypto.generateKeyPairSync("rsa", {
      //   modulusLength: 512,
      // });

      // const payload = JSON.stringify(data);

      // const signature = crypto.sign("sha256", Buffer.from(payload, 'utf-8'), {
      //   key: privateKey,
      //   padding: crypto.constants.RSA_PKCS1_PADDING,
      // });

      // data.signature = signature.toString('base64')

      // console.log(publicKey.export({format: 'pem', type: 'spki'}))

      // console.log(privateKey.export({type:'pkcs8', format: 'pem'}))

      // console.log(publicKey.asymmetricKeyDetails)

      // return sendQr(data)
    } else if (newEmail !== undefined && oldEmail === undefined) {
      return sendConfirmationEmail(data)
    }
  }))
}
