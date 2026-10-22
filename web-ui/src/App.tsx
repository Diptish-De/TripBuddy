import { useRef, useState } from 'react'

type Screen = 'home' | 'trips' | 'expenses' | 'activity' | 'profile'
type TripView = 'overview' | 'itinerary' | 'packing' | 'polls' | 'chat'

const Icon = ({ name, size = 20 }: { name: string; size?: number }) => {
  const paths: Record<string, React.ReactNode> = {
    home: <><path d="m3 10 9-7 9 7"/><path d="M5 9v11h14V9M9 20v-6h6v6"/></>,
    trips: <><path d="M5 7h14a2 2 0 0 1 2 2v9H3V9a2 2 0 0 1 2-2Z"/><path d="M8 7V5a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M3 13h18M8 13v2m8-2v2"/></>,
    wallet: <><path d="M4 5h14a2 2 0 0 1 2 2v12H4a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Z"/><path d="M16 11h5v5h-5a2.5 2.5 0 0 1 0-5Z"/></>,
    bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/></>,
    user: <><circle cx="12" cy="8" r="4"/><path d="M4 21c.7-4 3.3-6 8-6s7.3 2 8 6"/></>,
    plus: <path d="M12 5v14M5 12h14"/>,
    arrow: <path d="m9 18 6-6-6-6"/>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="3"/><path d="M7 3v4m10-4v4M3 10h18"/></>,
    pin: <><path d="M20 10c0 5-8 11-8 11S4 15 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/></>,
    check: <path d="m5 12 4 4L19 6"/>,
    users: <><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M17 11a4 4 0 0 0 0-8m5 18v-2a4 4 0 0 0-3-3.9"/></>,
    message: <path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4Z"/>,
    bag: <><path d="M5 8h14l1 13H4L5 8Z"/><path d="M9 8V6a3 3 0 0 1 6 0v2"/></>,
    vote: <><rect x="3" y="10" width="18" height="11" rx="2"/><path d="m8 10 4-7 4 7M8 16h8"/></>,
    gear: <><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-2.8 2.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-4V21a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1L4.2 17l.1-.1a1.7 1.7 0 0 0 .3-1.9A1.7 1.7 0 0 0 3 14H2.8v-4H3a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9L4.2 7 7 4.2l.1.1A1.7 1.7 0 0 0 9 4.6 1.7 1.7 0 0 0 10 3V2.8h4V3a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1L19.8 7l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v4H21a1.7 1.7 0 0 0-1.6 1Z"/></>,
    send: <path d="m22 2-7 20-4-9-9-4Z M22 2 11 13"/>,
    back: <path d="m15 18-6-6 6-6"/>,
    more: <><circle cx="5" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/></>,
  }
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">{paths[name]}</svg>
}

const Avatar = ({ initials, tone = 'blue' }: { initials: string; tone?: string }) => (
  <span className={`avatar avatar-${tone}`}>{initials}</span>
)

const TravelDoodles = () => (
  <svg className="travel-doodles" viewBox="0 0 390 235" fill="none" aria-hidden="true">
    <path className="doodle-flight" d="M38 68c38-42 88-44 117-14 26 27 6 61 38 75 38 17 65-41 119-21" />
    <path className="doodle-plane" d="m142 38 30 9-30 10 6-8-15-2 15-2-6-7Z" />
    <path className="doodle-squiggle" d="M28 166c12-14 22 14 34 0s22 14 34 0" />
    <g className="doodle-sun"><circle cx="327" cy="50" r="18"/><path d="M327 20v-9m0 78v-9m30-30h9m-78 0h9m51-21 7-7m-55 55 7-7m41 0 7 7m-55-55 7 7"/></g>
    <g className="doodle-cloud"><path d="M267 178c-12 0-14-18-2-22 2-18 29-20 35-4 15-3 22 21 5 26h-38Z"/><path d="M275 187h22"/></g>
    <path className="doodle-star" d="m82 30 4 9 10 2-8 7 2 10-8-5-9 5 2-10-7-7 10-2 4-9Z"/>
  </svg>
)

const SuitcaseBuddy = () => (
  <svg className="suitcase-buddy" viewBox="0 0 92 92" fill="none" aria-hidden="true">
    <path d="M34 26v-7c0-6 5-10 12-10s12 4 12 10v7" stroke="currentColor" strokeWidth="5" strokeLinecap="round"/>
    <rect x="15" y="25" width="62" height="54" rx="16" fill="#FF8A70" stroke="currentColor" strokeWidth="4"/>
    <path d="M30 25v54m32-54v54" stroke="currentColor" strokeWidth="3" opacity=".35"/>
    <circle cx="36" cy="48" r="3" fill="currentColor"/><circle cx="56" cy="48" r="3" fill="currentColor"/>
    <path d="M36 60c6 6 14 6 20 0" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/>
    <path d="m21 39-9-6m68 6 8-7" stroke="currentColor" strokeWidth="4" strokeLinecap="round"/>
    <circle cx="29" cy="82" r="5" fill="#FFD166" stroke="currentColor" strokeWidth="3"/><circle cx="64" cy="82" r="5" fill="#FFD166" stroke="currentColor" strokeWidth="3"/>
  </svg>
)

const CoastIllustration = () => (
  <svg className="coast-illustration" viewBox="0 0 430 230" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
    <rect width="430" height="230" fill="#BDEBFF"/>
    <circle cx="342" cy="55" r="30" fill="#FFD166" stroke="#353149" strokeWidth="3"/>
    <path d="M0 130 72 73l62 46 62-77 70 80 65-54 99 79v83H0Z" fill="#9F8BE8"/>
    <path d="m0 145 74-56 38 31 84-64 70 78 67-51 97 73v74H0Z" fill="#6FCBB1"/>
    <path d="M0 146c70-19 110 32 180 15 79-18 131-1 250-15v84H0Z" fill="#4FA9DC"/>
    <path d="M0 178c75-18 117 24 185 9 80-18 155 12 245-6v49H0Z" fill="#6EC7EA"/>
    <g stroke="#353149" strokeWidth="2">
      <path d="M46 127h40v51H46z" fill="#FFF7E9"/><path d="m41 127 25-19 25 19" fill="#FF8068"/><path d="M58 143h11v12H58zm16 0h7v21h-7z" fill="#FFD166"/>
      <path d="M104 118h43v54h-43z" fill="#FFE6F2"/><path d="m98 118 28-22 27 22" fill="#FFD166"/><path d="M115 134h10v12h-10zm18 0h8v22h-8z" fill="#8ED7FF"/>
      <path d="M283 126h47v49h-47z" fill="#FFF7E9"/><path d="m278 126 29-23 29 23" fill="#FF8068"/><path d="M292 141h10v12h-10zm18 0h9v23h-9z" fill="#9F8BE8"/>
      <path d="M350 119h38v54h-38z" fill="#FFF0C7"/><path d="m345 119 24-18 24 18" fill="#FF9ABF"/><path d="M360 135h9v11h-9zm15 0h7v22h-7z" fill="#6FCBB1"/>
    </g>
    <path d="M165 205c18-10 42-10 60 0" stroke="#FFF" strokeWidth="4" strokeLinecap="round" opacity=".8"/>
    <path d="m197 184 9 4-9 4 2-3h-8v-2h8l-2-3Z" fill="#FFD166" stroke="#353149"/>
    <g fill="#FFF" stroke="#353149" strokeWidth="2"><path d="M218 56c8-14 29-9 30 6 14-4 22 16 7 22h-39c-13-4-10-24 2-28Z"/></g>
  </svg>
)

const Nav = ({ screen, setScreen }: { screen: Screen; setScreen: (s: Screen) => void }) => (
  <nav className="bottom-nav">
    {([
      ['home', 'Home', 'home'], ['trips', 'Trips', 'trips'], ['expenses', 'Expenses', 'wallet'],
      ['activity', 'Activity', 'bell'], ['profile', 'Profile', 'user'],
    ] as [Screen, string, string][]).map(([id, label, icon]) => (
      <button className={screen === id ? 'nav-item active' : 'nav-item'} onClick={() => setScreen(id)} key={id}>
        <span className="nav-icon"><Icon name={icon}/>{id === 'activity' && <i/>}</span><small>{label}</small>
      </button>
    ))}
  </nav>
)

const Header = ({ title, eyebrow, action }: { title: string; eyebrow?: string; action?: React.ReactNode }) => (
  <header className="page-header"><div>{eyebrow && <p>{eyebrow}</p>}<h1>{title}</h1></div>{action}</header>
)

function Home({ goTrips }: { goTrips: () => void }) {
  return <main className="page home-page">
    <Header eyebrow="MONDAY, MAY 19" title="Good morning, User" action={<button className="avatar-button"><Avatar initials="U" tone="peach"/></button>}/>
    <section className="playful-banner"><div><span>YOUR TRAVEL BUDDY SAYS</span><strong>Ready, set, Amalfi!</strong><p>Only 24 days until the fun begins.</p></div><SuitcaseBuddy/></section>
    <section className="hero-card" onClick={goTrips}>
      <div className="hero-image" role="img" aria-label="Blue Mediterranean coast">
        <TravelDoodles/>
        <div className="hero-top"><span className="pill light">In 24 days</span><button className="round-button"><Icon name="arrow"/></button></div>
        <div className="hero-copy"><p>Your next adventure</p><h2>Amalfi Coast</h2><div><Icon name="calendar" size={16}/> Jun 12–19 <span/> 7 days</div></div>
      </div>
      <div className="trip-meta">
        <div className="avatar-stack"><Avatar initials="U" tone="peach"/><Avatar initials="AJ" tone="mint"/><Avatar initials="SL" tone="purple"/><span className="avatar avatar-more">+2</span></div>
        <strong>5 travelers</strong><span className="meta-spacer"/><span className="status-dot"/> All set
      </div>
    </section>
    <section className="section-block">
      <div className="section-title decorated-title"><div><p>QUICK GLANCE</p><h2>Trip at a glance <span>✦</span></h2></div><button onClick={goTrips}>View trip</button></div>
      <div className="stats-grid">
        <div className="stat-card stat-card-wide"><span className="icon-box purple"><Icon name="wallet"/></span><div><p>Total trip expenses</p><strong>₹18,400</strong><small>18 expenses · updated today</small></div><button onClick={goTrips}><Icon name="arrow" size={18}/></button></div>
        <div className="stat-card"><span className="icon-box blue"><Icon name="wallet"/></span><p>Budget left</p><strong>₹31,600</strong><small>of ₹50,000</small></div>
        <div className="stat-card"><span className="icon-box green"><Icon name="check"/></span><p>Ready to pack</p><strong>72%</strong><small>18 of 25 items</small></div>
      </div>
    </section>
    <section className="section-block activity-preview">
      <div className="section-title"><h2>Latest activity</h2><button>See all</button></div>
      <div className="activity-row"><Avatar initials="AJ" tone="mint"/><div><p><strong>Alex</strong> added Dinner at Da Gemma</p><small>12 minutes ago</small></div><span className="activity-icon"><Icon name="calendar"/></span></div>
      <div className="activity-row"><Avatar initials="SL" tone="purple"/><div><p><strong>Sofia</strong> paid ₹2,100 for train tickets</p><small>1 hour ago</small></div><span className="activity-icon green"><Icon name="wallet"/></span></div>
    </section>
  </main>
}

const tripTools: { id: TripView; label: string; icon: string }[] = [
  { id: 'itinerary', label: 'Itinerary', icon: 'calendar' }, { id: 'packing', label: 'Packing', icon: 'bag' },
  { id: 'polls', label: 'Polls', icon: 'vote' }, { id: 'chat', label: 'Group chat', icon: 'message' },
]

function Trip({ view, setView }: { view: TripView; setView: (v: TripView) => void }) {
  if (view === 'itinerary') return <Itinerary back={() => setView('overview')}/>
  if (view === 'packing') return <Packing back={() => setView('overview')}/>
  if (view === 'polls') return <Polls back={() => setView('overview')}/>
  if (view === 'chat') return <Chat back={() => setView('overview')}/>
  return <main className="page trip-page">
    <div className="trip-cover"><CoastIllustration/><div className="trip-cover-actions"><button className="round-button translucent"><Icon name="back"/></button><button className="round-button translucent"><Icon name="more"/></button></div><div className="trip-cover-copy"><span className="pill light">UPCOMING</span><h1>Amalfi Coast</h1><p><Icon name="pin" size={15}/> Italy · Jun 12–19</p></div></div>
    <div className="trip-content">
      <div className="people-strip"><div className="avatar-stack"><Avatar initials="U" tone="peach"/><Avatar initials="AJ" tone="mint"/><Avatar initials="SL" tone="purple"/><Avatar initials="NO" tone="gold"/></div><button><Icon name="users" size={17}/> 5 members</button></div>
      <div className="budget-card"><div><p>TRIP BUDGET</p><strong>₹18,400 <span>spent</span></strong></div><div className="budget-right"><b>₹31,600 left</b><span>63% remaining</span></div><div className="progress"><i style={{width:'37%'}}/></div></div>
      <h2 className="subheading">Plan together</h2>
      <div className="tool-grid">{tripTools.map(tool => <button key={tool.id} onClick={() => setView(tool.id)}><span className={`icon-box ${tool.id}`}><Icon name={tool.icon}/></span><strong>{tool.label}</strong><Icon name="arrow" size={18}/></button>)}</div>
      <div className="section-title today-title"><div><p>TODAY · JUNE 14</p><h2>On the itinerary</h2></div><button onClick={() => setView('itinerary')}>Full schedule</button></div>
      <div className="timeline-mini"><span className="time">9:30</span><i/><div><strong>Boat tour to Capri</strong><p>Marina Grande · 4 attending</p></div><span className="pill blue-pill">Booked</span></div>
      <div className="timeline-mini"><span className="time">19:00</span><i className="amber"/><div><strong>Dinner at Da Gemma</strong><p>Amalfi · Reservation pending</p></div></div>
    </div>
  </main>
}

function SubHeader({ title, subtitle, back, action }: { title: string; subtitle: string; back: () => void; action?: React.ReactNode }) {
  return <header className="sub-header"><button onClick={back}><Icon name="back"/></button><div><h1>{title}</h1><p>{subtitle}</p></div>{action || <button><Icon name="more"/></button>}</header>
}

function Itinerary({ back }: { back: () => void }) {
  return <main className="page white-page"><SubHeader title="Itinerary" subtitle="Amalfi Coast" back={back} action={<button className="primary-icon"><Icon name="plus"/></button>}/>
    <div className="date-strip">{[['THU','12'],['FRI','13'],['SAT','14'],['SUN','15'],['MON','16']].map((d,i)=><button className={i===2?'selected':''} key={d[1]}><small>{d[0]}</small><strong>{d[1]}</strong>{i===2&&<i/>}</button>)}</div>
    <div className="day-summary"><span>DAY 3</span><h2>Saturday in Capri</h2><p>3 activities · Mostly sunny, 26°</p></div>
    <div className="full-timeline">
      <div className="line"/>
      <div className="event"><time>9:30<br/><small>AM</small></time><i/><div className="event-card blue-event"><span className="pill blue-pill">BOOKED</span><h3>Boat tour to Capri</h3><p><Icon name="pin" size={15}/> Marina Grande</p><footer><div className="mini-stack"><Avatar initials="U" tone="peach"/><Avatar initials="AJ" tone="mint"/><Avatar initials="SL" tone="purple"/></div><span>4 attending</span></footer></div></div>
      <div className="event"><time>1:00<br/><small>PM</small></time><i/><div className="event-card"><span className="pill amber-pill">FLEXIBLE</span><h3>Lunch at Il Riccio</h3><p><Icon name="pin" size={15}/> Anacapri</p></div></div>
      <div className="event"><time>7:00<br/><small>PM</small></time><i/><div className="event-card"><span className="pill blue-pill">PENDING</span><h3>Dinner at Da Gemma</h3><p><Icon name="pin" size={15}/> Via Fra Gerardo Sasso</p></div></div>
    </div>
  </main>
}

function Packing({ back }: { back: () => void }) {
  const [checked, setChecked] = useState([true,true,false,true,false])
  const items = ['Passport & travel documents','Phone charger','Swimsuit','Walking shoes','Sunscreen SPF 50']
  const done = checked.filter(Boolean).length
  return <main className="page white-page"><SubHeader title="Packing list" subtitle="Amalfi Coast" back={back} action={<button className="primary-icon"><Icon name="plus"/></button>}/>
    <div className="packing-summary"><div><strong>{done}/{items.length}</strong><span>items packed</span></div><div className="ring">{Math.round(done/items.length*100)}%</div></div>
    <div className="progress wide"><i style={{width:`${done/items.length*100}%`}}/></div>
    <div className="list-heading"><div><span className="icon-box blue"><Icon name="bag"/></span><div><h2>Essentials</h2><p>{done} of {items.length} packed</p></div></div><Icon name="more"/></div>
    <div className="checklist">{items.map((item,i)=><button key={item} onClick={()=>setChecked(c=>c.map((v,n)=>n===i?!v:v))} className={checked[i]?'done':''}><span className="checkbox">{checked[i]&&<Icon name="check" size={15}/>}</span><span>{item}</span><Avatar initials={i%2?'AJ':'U'} tone={i%2?'mint':'peach'}/></button>)}</div>
    <button className="add-row"><Icon name="plus" size={18}/> Add an item</button>
  </main>
}

function Polls({ back }: { back: () => void }) {
  const [vote, setVote] = useState(0)
  return <main className="page"><SubHeader title="Group polls" subtitle="Decide together" back={back} action={<button className="primary-icon"><Icon name="plus"/></button>}/>
    <div className="poll-card"><div className="poll-top"><span className="pill blue-pill">OPEN</span><small>Closes tomorrow</small></div><h2>Which day trip should we book?</h2><p>Created by Alex · 4 of 5 voted</p>
      {['Path of the Gods hike','Capri boat tour','Pompeii & Vesuvius'].map((item,i)=><button className={vote===i?'poll-option voted':'poll-option'} onClick={()=>setVote(i)} key={item}><span className="radio">{vote===i&&<i/>}</span><div><strong>{item}</strong><span><i style={{width:`${[25,50,25][i]}%`}}/></span></div><b>{[1,2,1][i]}</b></button>)}
      <div className="poll-footer"><div className="mini-stack"><Avatar initials="AJ" tone="mint"/><Avatar initials="SL" tone="purple"/><Avatar initials="U" tone="peach"/></div><strong>Capri is leading</strong></div>
    </div>
    <div className="poll-card closed"><div className="poll-top"><span className="pill neutral-pill">CLOSED</span><small>May 16</small></div><h2>Where should we stay?</h2><p>Winner: Amalfi · 4 votes</p></div>
  </main>
}

function Chat({ back }: { back: () => void }) {
  const [messages, setMessages] = useState(['I found a boat tour with a stop at the Blue Grotto. Thoughts?','Looks perfect! I’m in.','Same here — should we book the 9:30 slot?'])
  const [text, setText] = useState('')
  const send=()=>{if(text.trim()){setMessages([...messages,text]);setText('')}}
  return <main className="page white-page chat-page"><SubHeader title="Amalfi crew" subtitle="5 members · 3 online" back={back}/>
    <div className="messages"><div className="day-divider">TODAY</div>{messages.map((m,i)=><div className={i===messages.length-1&&i>2?'message mine':'message'} key={i}>{!(i===messages.length-1&&i>2)&&<Avatar initials={i===0?'AJ':i===1?'SL':'NO'} tone={i===0?'mint':i===1?'purple':'gold'}/>}<div><small>{i===0?'Alex':i===1?'Sofia':i===2?'Noah':'You'} · {9+i}:2{i}</small><p>{m}</p>{i===0&&<button className="link-preview"><span className="preview-art">CAPRI</span><span><strong>Capri Dream Tours</strong><small>Full day private boat · ₹7,900 pp</small></span></button>}</div></div>)}</div>
    <div className="composer"><button><Icon name="plus"/></button><input value={text} onChange={e=>setText(e.target.value)} onKeyDown={e=>e.key==='Enter'&&send()} placeholder="Message the group"/><button className="send" onClick={send}><Icon name="send" size={18}/></button></div>
  </main>
}

function Expenses() {
  const [showAdd, setShowAdd] = useState(false)
  const [showQr, setShowQr] = useState<string | null>(null)
  const [filter, setFilter] = useState('All')
  const [expenseScope, setExpenseScope] = useState<'group' | 'mine'>('group')
  const [amount, setAmount] = useState('4000')
  const friends = [
    { name: 'User', initials: 'U', tone: 'peach', upi: 'user@upi' },
    { name: 'Alex Johnson', initials: 'AJ', tone: 'mint', upi: 'alexj@oksbi' },
    { name: 'Sofia Lee', initials: 'SL', tone: 'purple', upi: 'sofialee@okhdfcbank' },
    { name: 'Noah Williams', initials: 'NO', tone: 'gold', upi: 'noahw@okicici' },
    { name: 'Emma Chen', initials: 'EC', tone: 'blue', upi: 'emmachen@paytm' },
  ]
  const [included, setIncluded] = useState(friends.map(() => true))
  const dinerCount = included.filter(Boolean).length
  const share = dinerCount ? Number(amount || 0) / dinerCount : 0
  const qrFriend = friends.find(friend => friend.name === showQr)
  return <main className="page expenses-page">
    <Header title="Expenses" eyebrow="AMALFI COAST" action={<button className="primary-icon" onClick={()=>setShowAdd(true)}><Icon name="plus"/></button>}/>
    <div className="scope-switch"><button className={expenseScope==='group'?'active':''} onClick={()=>setExpenseScope('group')}><Icon name="users" size={16}/> Group expenses</button><button className={expenseScope==='mine'?'active':''} onClick={()=>setExpenseScope('mine')}><Icon name="user" size={16}/> My expenses</button></div>
    <div className="balance-card"><div className="balance-confetti"><i/><i/><i/><i/></div><p>YOUR BALANCE</p><strong>+₹1,540</strong><span>You are owed overall</span><div><button>Settle up</button><button>View balances <Icon name="arrow" size={16}/></button></div></div>
    {expenseScope==='group'?<div className="spend-row"><div><span className="icon-box blue"><Icon name="wallet"/></span><div><p>Group total</p><strong>₹18,400</strong></div></div><div><p>Your group share</p><strong>₹2,180</strong></div></div>:<div className="my-total-card"><div className="my-total-head"><span><small>MY TOTAL EXPENSES</small><strong>₹5,430</strong></span><span className="pill blue-pill">THIS TRIP</span></div><div className="expense-equation"><span><small>Personal spending</small><strong>₹3,250</strong></span><b>+</b><span><small>Group contributions</small><strong>₹2,180</strong></span><b>=</b><span><small>My total</small><strong>₹5,430</strong></span></div><p><Icon name="check" size={14}/> Your share from every group expense is automatically included here.</p></div>}
    <div className="section-title members-title"><div><p>TRIP GROUP</p><h2>Friends & payments</h2></div><button><Icon name="plus" size={15}/> Invite</button></div>
    <div className="friend-strip">{friends.map(friend=><button key={friend.name} onClick={()=>setShowQr(friend.name)}><Avatar initials={friend.initials} tone={friend.tone}/><strong>{friend.name.split(' ')[0]}</strong><small>UPI QR</small></button>)}</div>
    <div className="filter-tabs">{['All','Food','Travel','Stay'].map(x=><button onClick={()=>setFilter(x)} className={filter===x?'active':''} key={x}>{x}</button>)}</div>
    {expenseScope==='group'?<div className="expense-list"><p className="date-label">GROUP ACTIVITY · TODAY</p>
      <Expense title="Group lunch" meta="Paid by Alex · all 5 friends ate" amount="₹4,000" icon="L" note="Your share ₹800" />
      <Expense title="Train tickets" meta="Paid by Sofia · split 5 ways" amount="₹2,100" icon="🚆" note="Your share ₹420" />
      <Expense title="Dinner at Marina Grande" meta="Paid by you · split 5 ways" amount="₹3,500" icon="🍝" highlight note="You paid" />
      <p className="date-label">YESTERDAY</p>
      <Expense title="Villa deposit" meta="Paid by Alex · split 5 ways" amount="₹8,800" icon="⌂" note="Your share ₹1,760" />
    </div>:<div className="expense-list"><p className="date-label">MY PERSONAL SPENDING</p>
      <Expense title="Souvenirs" meta="Personal · only you" amount="₹1,450" icon="S" note="Personal" />
      <Expense title="Coffee & breakfast" meta="Personal · only you" amount="₹620" icon="C" note="Personal" />
      <Expense title="Local shopping" meta="Personal · only you" amount="₹1,180" icon="B" note="Personal" />
      <p className="date-label contribution-label">MY GROUP CONTRIBUTIONS · INCLUDED ABOVE</p>
      <Expense title="Group lunch share" meta="From Alex's ₹4,000 lunch bill" amount="₹800" icon="L" note="Auto-added" />
      <Expense title="Villa share" meta="From the group stay expense" amount="₹1,380" icon="H" note="Auto-added" />
    </div>}
    {showAdd&&<div className="sheet-backdrop" onClick={()=>setShowAdd(false)}><section className="sheet expense-sheet" onClick={e=>e.stopPropagation()}><div className="sheet-handle"/><div className="sheet-title"><h2>Add group expense</h2><button onClick={()=>setShowAdd(false)}>×</button></div><label>WHAT WAS IT FOR?<input autoFocus defaultValue="Group lunch"/></label><label>TOTAL AMOUNT<div className="amount-input"><span>₹</span><input type="number" value={amount} onChange={e=>setAmount(e.target.value)}/></div></label><div className="form-row"><label>CATEGORY<button className="select-button">Food & drinks <span>⌄</span></button></label><label>PAID BY<button className="select-button">Alex <span>⌄</span></button></label></div><div className="split-heading"><div><strong>Who had this?</strong><small>Select only the friends who ate</small></div><button onClick={()=>setIncluded(friends.map(()=>true))}>Select all</button></div><div className="diner-list">{friends.map((friend,index)=><button key={friend.name} onClick={()=>setIncluded(current=>current.map((value,i)=>i===index?!value:value))} className={included[index]?'selected':''}><Avatar initials={friend.initials} tone={friend.tone}/><span><strong>{friend.name}</strong><small>{included[index]?`₹${share.toFixed(0)} share`:'Not included'}</small></span><i>{included[index]&&<Icon name="check" size={14}/>}</i></button>)}</div><div className="split-total"><span><small>TOTAL TO SPLIT</small><strong>₹{Number(amount || 0).toLocaleString()}</strong></span><Icon name="arrow"/><span><small>{dinerCount} PEOPLE · EACH</small><strong>₹{share.toFixed(2)}</strong></span></div><button className="primary-button" disabled={!dinerCount} onClick={()=>setShowAdd(false)}>Save & request ₹{share.toFixed(0)} each</button></section></div>}
    {qrFriend&&<div className="sheet-backdrop qr-backdrop" onClick={()=>setShowQr(null)}><section className="sheet qr-sheet" onClick={e=>e.stopPropagation()}><div className="sheet-handle"/><div className="qr-person"><Avatar initials={qrFriend.initials} tone={qrFriend.tone}/><div><h2>Pay {qrFriend.name}</h2><p>{qrFriend.upi}</p></div></div><div className="qr-code" aria-label={`UPI QR code for ${qrFriend.name}`}><div className="qr-grid">{Array.from({length:81},(_,i)=><i className={(i*7+i%5)%3===0||[0,1,2,9,11,18,19,20,6,7,8,15,17,24,25,26,54,55,56,63,65,72,73,74].includes(i)?'dark':''} key={i}/>)}</div><span>UPI</span></div><p className="qr-help">Scan with any UPI app to pay securely</p><button className="primary-button" onClick={()=>setShowQr(null)}>Done</button></section></div>}
  </main>
}

function Expense({title,meta,amount,icon,highlight,note}:{title:string;meta:string;amount:string;icon:string;highlight?:boolean;note?:string}) {
  return <button className="expense-row"><span className="expense-emoji">{icon}</span><div><strong>{title}</strong><p>{meta}</p></div><div><strong>{amount}</strong><small className={highlight?'positive':''}>{note || (highlight?'+₹1,450':'You owe ₹420')}</small></div></button>
}

function Activity() {
  return <main className="page"><Header title="Activity" eyebrow="STAY IN THE LOOP" action={<button className="round-button bordered"><Icon name="check"/></button>}/>
    <div className="filter-tabs activity-tabs"><button className="active">All activity</button><button>Mentions</button><button>Mine</button></div>
    <div className="feed"><p className="date-label">TODAY</p>
      <Feed avatar="AJ" tone="mint" text={<><strong>Alex</strong> added <b>Boat tour to Capri</b> to the itinerary</>} time="12 min" icon="calendar"/>
      <Feed avatar="SL" tone="purple" text={<><strong>Sofia</strong> paid <b>₹2,100</b> for train tickets</>} time="1 hr" icon="wallet"/>
      <Feed avatar="NO" tone="gold" text={<><strong>Noah</strong> voted for <b>Capri boat tour</b></>} time="2 hr" icon="vote"/>
      <Feed avatar="U" tone="peach" text={<><strong>You</strong> packed <b>Passport & travel documents</b></>} time="4 hr" icon="bag"/>
      <p className="date-label">YESTERDAY</p>
      <Feed avatar="AJ" tone="mint" text={<><strong>Alex</strong> invited <b>Emma Chen</b> to the trip</>} time="Yesterday" icon="users"/>
    </div>
  </main>
}

function Feed({avatar,tone,text,time,icon}:{avatar:string;tone:string;text:React.ReactNode;time:string;icon:string}) {
  return <div className="feed-row"><div className="avatar-wrap"><Avatar initials={avatar} tone={tone}/><i><Icon name={icon} size={12}/></i></div><div><p>{text}</p><small>{time}</small></div><button><Icon name="arrow" size={17}/></button></div>
}

function Profile() {
  const [notifications,setNotifications]=useState(true)
  return <main className="page profile-page"><Header title="Profile"/>
    <div className="profile-card"><div className="large-avatar">U<button><Icon name="plus" size={16}/></button></div><h2>User</h2><p>user@example.com</p><button>Edit profile</button></div>
    <p className="settings-label">PREFERENCES</p><div className="settings-card">
      <button><span className="icon-box blue"><Icon name="bell"/></span><div><strong>Notifications</strong><small>Trip updates and reminders</small></div><span onClick={(e)=>{e.stopPropagation();setNotifications(!notifications)}} className={notifications?'toggle on':'toggle'}><i/></span></button>
      <button><span className="icon-box purple"><Icon name="gear"/></span><div><strong>Appearance</strong><small>Light theme</small></div><Icon name="arrow" size={18}/></button>
      <button><span className="icon-box green"><Icon name="wallet"/></span><div><strong>Currency</strong><small>INR · Indian Rupee (₹)</small></div><Icon name="arrow" size={18}/></button>
    </div>
    <p className="settings-label">YOUR TRIPS</p><div className="settings-card"><button><span className="icon-box blue"><Icon name="trips"/></span><div><strong>3 trips</strong><small>2 upcoming · 1 past</small></div><Icon name="arrow" size={18}/></button></div>
  </main>
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('home')
  const [tripView, setTripView] = useState<TripView>('overview')
  const [toast, setToast] = useState('')
  const toastTimer = useRef<ReturnType<typeof setTimeout> | null>(null)
  const navigate = (s: Screen) => { setScreen(s); if(s==='trips') setTripView('overview') }
  const showFeedback = (message: string) => {
    setToast(message)
    if (toastTimer.current) clearTimeout(toastTimer.current)
    toastTimer.current = setTimeout(() => setToast(''), 2200)
  }
  const handleButtonClick = (event: React.MouseEvent<HTMLDivElement>) => {
    const button = (event.target as HTMLElement).closest('button')
    if (!button || button.disabled || button.classList.contains('nav-item')) return
    const label = (button.textContent || '').replace(/\s+/g, ' ').trim()

    if (button.classList.contains('avatar-button')) {
      navigate('profile')
      showFeedback('Profile opened')
      return
    }
    if (button.closest('.trip-cover-actions') && button === button.parentElement?.firstElementChild) {
      navigate('home')
      showFeedback('Back to home')
      return
    }
    if (button.closest('.date-strip')) {
      button.parentElement?.querySelectorAll('button').forEach(item => item.classList.remove('selected'))
      button.classList.add('selected')
      showFeedback(`Schedule changed to ${label}`)
      return
    }
    if (label === 'See all') {
      navigate('activity')
      showFeedback('Showing all trip activity')
      return
    }

    const messages: Record<string, string> = {
      'Invite': 'Invite link copied — ready to share',
      'Settle up': 'Settlement options opened',
      'View balances': 'Showing who owes whom',
      'Edit profile': 'Profile editor opened',
      'Add an item': 'New packing item ready',
      'Full schedule': 'Full itinerary opened',
      'Select all': 'Everyone has been selected',
      'Done': 'Payment details closed',
      'Appearance Light theme': 'Appearance settings opened',
      'Currency INR · Indian Rupee (₹)': 'Currency settings opened',
      '3 trips 2 upcoming · 1 past': 'Your trips opened',
      'Notifications Trip updates and reminders': 'Notification preference updated',
    }
    if (messages[label]) {
      showFeedback(messages[label])
    } else if (button.classList.contains('primary-icon')) {
      showFeedback('New item flow opened')
    } else if (button.classList.contains('round-button') || !label) {
      showFeedback('More options opened')
    } else if (!button.closest('.composer') && !button.closest('.checklist') && !button.closest('.poll-option')) {
      showFeedback(`${label.slice(0, 38)}${label.length > 38 ? '…' : ''}`)
    }
  }
  return <div className="app-shell" onClickCapture={handleButtonClick}>
    <div className="status-bar"><span>9:41</span><div><i/><i/><i/></div></div>
    {screen==='home'&&<Home goTrips={()=>navigate('trips')}/>}
    {screen==='trips'&&<Trip view={tripView} setView={setTripView}/>}
    {screen==='expenses'&&<Expenses/>}
    {screen==='activity'&&<Activity/>}
    {screen==='profile'&&<Profile/>}
    {tripView==='overview'&&<Nav screen={screen} setScreen={navigate}/>}
    <div className={toast?'action-toast visible':'action-toast'} role="status" aria-live="polite"><span><Icon name="check" size={16}/></span>{toast}</div>
  </div>
}
